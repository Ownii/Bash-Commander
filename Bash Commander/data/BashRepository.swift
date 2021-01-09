//
//  BashRepository.swift
//  Bash Commander
//
//  Created by Martin Förster on 11.11.20.
//

import Foundation
import RxSwift

struct BashError: Error {
    var output: String
}

protocol BashRepository {
    func execute(cmd: String, workingDirectory: String) -> Completable
    func getOutput() -> Observable<CommandOutput>
}

class BashRepositoryImpl : BashRepository {
    
    private lazy var outputPublisher: PublishSubject<CommandOutput> = { PublishSubject<CommandOutput>() }()
    
    func execute(cmd: String, workingDirectory: String) -> Completable {
        return self.getEnv().flatMap { env in
            self.execute(cmd: cmd, workingDirectory: workingDirectory, env: env)
        }.map { output -> Void in
            self.outputPublisher.onNext(CommandOutput(state: .SUCCEEDED, output: output))
            return ()
        }.asCompletable()
        .do(onError: { (err: Error) in
            if let bashError = err as? BashError {
                
                self.outputPublisher.onNext(CommandOutput(state: .FAILED, output: "\(bashError.output)"))
            }
            else {
                self.outputPublisher.onNext(CommandOutput(state: .FAILED, output: "\(err.localizedDescription)"))
            }
        })
    }
    
    
    func getOutput() -> Observable<CommandOutput> {
        outputPublisher
    }
    
    private func getEnv() -> Single<[String: String]> {
        var envShell = ProcessInfo.processInfo.environment
        let envPath = envShell["PATH"]! as String
        
        return execute(cmd: "eval $(/usr/libexec/path_helper -s) ; echo $PATH").map { paths in
            let pathsOneliner = paths.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil)
            envShell["PATH"] = "\(pathsOneliner):\(envPath)"
            return envShell
        }
    }
    
    private func execute(cmd: String, workingDirectory: String? = nil, env: [String: String]? = [:]) -> Single<String> {
        return Single<String>.create { single in
            let task = Process()
            let pipe = Pipe()

            task.standardOutput = pipe
            task.standardError = pipe
            task.arguments = ["bash", "-c", "-i", "-l", cmd]
            if( workingDirectory != nil ) {
                task.currentDirectoryPath = workingDirectory!
            }
            task.environment = env
            task.launchPath = "/usr/bin/env"
            try! task.run()
            self.outputPublisher.onNext(CommandOutput(state: .RUNNING, task: task))
            task.terminationHandler = { process in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if( process.terminationStatus > 0 ) {
                    single(.failure(BashError(output: String(data: data, encoding: .utf8)!)))
                    
                }
                else {
                    let result = String(data: data, encoding: .utf8)!
                    single(.success(result))
                }
            }
            return Disposables.create {
                if( task.isRunning ) {
                    task.interrupt()
                }
            }
        }
        
    }
}


