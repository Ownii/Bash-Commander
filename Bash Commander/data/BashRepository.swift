//
//  BashRepository.swift
//  Bash Commander
//
//  Created by Martin Förster on 11.11.20.
//

import Foundation
import RxSwift

enum BashError: Error {
    case output(String)
    case envError(String)
    case workingDirectoryNotExists
    case exit(Int32)
}

protocol BashRepository {
    func execute(cmd: String, workingDirectory: String)
    func cancelRunningExecution()
    var executions: Observable<Observable<String>> { get }
}

class BashRepositoryImpl : BashRepository {
    
    

    private let outputPublisher: BehaviorSubject<Observable<String>> = { BehaviorSubject<Observable<String>>(value: Observable.empty()) }()
    
    private var runningProcess: Process? = nil
    
    var executions: Observable<Observable<String>> {
        outputPublisher
    }
    
    func cancelRunningExecution() {
        if( runningProcess?.isRunning ?? false ) {
            runningProcess?.interrupt()
        }
    }
    
    func execute(cmd: String, workingDirectory: String) {
        print("execute \(cmd)")
        
        if( runningProcess?.isRunning ?? false) {
            print("already running")
            return
        }
        
        let execution = Observable<String>.create { observer in
            
            if( !self.directoryExists(directory: workingDirectory) ) {
                observer.onError(BashError.workingDirectoryNotExists)
                return Disposables.create()
            }
        
            do {
                let env = try self.getEnv()
                self.runningProcess = self.executeAndPublish(command: cmd, workingDirectory: workingDirectory, env: env, observer: observer)
            } catch let error {
                self.runningProcess = nil
                observer.onError(error)
            }
            
            return Disposables.create {
                self.cancelRunningExecution()
            }
        }
        
        let sharedExecution = execution.share(replay: 999, scope: .forever)
        
        outputPublisher.onNext(sharedExecution)
    }
    
    private func getEnv() throws -> [String: String] {
        var envShell = ProcessInfo.processInfo.environment
        let envPath = envShell["PATH"]! as String
        
        let command = "eval $(/usr/libexec/path_helper -s) ; echo $PATH"
        let paths = try! simpleExecute(command: command)
        let pathsOneliner = paths.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil)
        envShell["PATH"] = "\(pathsOneliner):\(envPath)"

        return envShell
    }
    
    private func simpleExecute(command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["bash", "-c", "-i", "-l", command]
        task.launchPath = "/usr/bin/env"

        try! task.run()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if( task.terminationStatus > 0 ) {
            let result = String(data: data, encoding: .utf8)!
            throw BashError.envError(result)
        }
        let result = String(data: data, encoding: .utf8)!
        
        return result
    }
    
    private func executeAndPublish(command: String, workingDirectory: String, env: [String: String], observer: AnyObserver<String>) -> Process {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["bash", "-c", "-i", "-l", command]
        task.currentDirectoryPath = workingDirectory
        task.environment = env
        task.launchPath = "/usr/bin/env"
        
        let reader = pipe.fileHandleForReading

        reader.readabilityHandler = { reader in
            let data = reader.availableData

            if data.count > 0 {
                print("new data received")
                if let output = String(data: data, encoding: String.Encoding.utf8) {
                    print("output: \(output)")
                    observer.onNext(output)
                }
            }
        }
        
        task.terminationHandler = { process in
            if ( process.terminationStatus > 0 ) {
                print("terminated due to failure")
                self.runningProcess = nil
                observer.onError(BashError.exit(process.terminationStatus))
            }
            else {
                print("completed")
                self.runningProcess = nil
                observer.onCompleted()
            }
        }
        
        try! task.run()
        
        return task
    }
    
    func directoryExists(directory: String) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: directory, isDirectory:&isDirectory)
        return exists && isDirectory.boolValue
    }
    
}


