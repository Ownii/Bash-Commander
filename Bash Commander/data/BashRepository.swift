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
            self.execute(cmd: cmd, workingDirectory: workingDirectory, env: env, publish: true)
        }.map { output -> Void in
            self.outputPublisher.onNext(CommandOutput(state: .SUCCEEDED, output: Observable.just(output)))
            return ()
        }.asCompletable()
        .do(onError: { (err: Error) in
            self.outputPublisher.onNext(CommandOutput(state: .FAILED, output: Observable.error(err)))
//            if let bashError = err as? BashError {
//                self.outputPublisher.onNext(CommandOutput(state: .FAILED, output: "\(bashError.output)"))
//            }
//            else {
//                self.outputPublisher.onNext(CommandOutput(state: .FAILED, output: "\(err.localizedDescription)"))
//            }
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
    
    private func execute(cmd: String, workingDirectory: String? = nil, env: [String: String]? = [:], publish: Bool = false) -> Single<String> {
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
            
            
            if(publish) {
                self.outputPublisher.onNext(CommandOutput(state: .RUNNING, task: task, output: self.readOutput(pipe: pipe)))
            }
            
            
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
            
            try! task.run()
            
            return Disposables.create {
                if( task.isRunning ) {
                    task.interrupt()
                }
            }
        }
        
    }
    
    private func readOutput(pipe: Pipe) -> Observable<String> {
        return Observable.create { observable in
            let reader = pipe.fileHandleForReading
            reader.waitForDataInBackgroundAndNotify()
            
            var progressObserver: NSObjectProtocol!
            progressObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: reader, queue: nil) { notification -> Void in
                let data = reader.availableData
                
                if data.count > 0 {
                    if let output = String(data: data, encoding: String.Encoding.utf8) {
                        observable.onNext(output)
                    }
                    reader.waitForDataInBackgroundAndNotify()
                } else {
                    observable.onCompleted()
                    if let observer = progressObserver {
                        NotificationCenter.default.removeObserver(observer)
                    }
                }
            }
            
            return Disposables.create {
                if let observer = progressObserver {
                    NotificationCenter.default.removeObserver(observer)
                }
            }
        }
    }
}


