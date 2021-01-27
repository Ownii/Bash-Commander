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
    func execute(cmd: String, workingDirectory: String)
    func getCommandOutput() -> Observable<Observable<String>>
}

class BashRepositoryImpl : BashRepository {
    
    private lazy var outputPublisher: BehaviorSubject<Observable<String>> = { BehaviorSubject<Observable<String>>(value: Observable.empty()) }()
    
    func execute(cmd: String, workingDirectory: String) {
        
        
        
        return self.getEnv().flatMap { env in
            self.execute(cmd: cmd, workingDirectory: workingDirectory, env: env, publish: true)
        }.map { output -> Void in
            self.outputPublisher.onNext(CommandOutput(state: .SUCCEEDED, output: Observable.just(output)))
            return ()
        }.asCompletable()
        .do(onError: { (err: Error) in
            self.outputPublisher.onNext(CommandOutput(state: .FAILED, output: Observable.error(err)))
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
            
            
            let output = Observable<String>.create { observable in
                let reader = pipe.fileHandleForReading
                
                reader.readabilityHandler = { reader in
                    let data = reader.availableData

                    if data.count > 0 {
                        if let output = String(data: data, encoding: String.Encoding.utf8) {
                            observable.onNext(output)
                        }
                    } else {
                        observable.onCompleted()
                    }
                }
                
                return Disposables.create {
                    reader.readabilityHandler = nil
                }
            }
            
            if(publish) {
                self.outputPublisher.onNext(CommandOutput(state: .RUNNING, task: task, output: output.share(replay: 999)))
            }
            
            var completeOutput = ""
            let outputDisposable = output.subscribe(onNext: { output in
                completeOutput.append(output)
            }, onCompleted: {
                single(.success(completeOutput))
            })
            
//            task.terminationHandler = { process in
//                let data = pipe.fileHandleForReading.readDataToEndOfFile()
//                if( process.terminationStatus > 0 ) {
//                    single(.failure(BashError(output: String(data: data, encoding: .utf8)!)))
//                }
//                else {
//                    let result = String(data: data, encoding: .utf8)!
//                    single(.success(result))
//                }
//            }
            
            try! task.run()
            
            return Disposables.create {
                outputDisposable.dispose()
                if( task.isRunning ) {
                    task.interrupt()
                }
            }
        }
        
    }
    
    private func readOutput(pipe: Pipe) -> Observable<String> {
        return Observable.create { observable in
            let reader = pipe.fileHandleForReading
            
            reader.readabilityHandler = { reader in
                let data = reader.availableData

                if data.count > 0 {
                    if let output = String(data: data, encoding: String.Encoding.utf8) {
                        observable.onNext(output)
                    }
                } else {
                    observable.onCompleted()
                }
            }
            
            return Disposables.create {
                reader.readabilityHandler = nil
            }
        }
    }
}


