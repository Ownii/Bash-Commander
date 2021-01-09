//
//  IoCConfigurator.swift
//  Bash Commander
//
//  Created by Martin Förster on 12.11.20.
//

import Cocoa
import Foundation
import Swift_IoC_Container

class IoCConfigurator {
    func configure() {
        IoC.shared.registerLazySingleton(BashRepository.self) { BashRepositoryImpl() }
        IoC.shared.registerLazySingleton(CommandsRepository.self) { CommandsRepositoryImpl() }
        IoC.shared.registerLazySingleton(NSPersistentContainer.self) {
            let container = NSPersistentContainer(name: "Commands")
            container.loadPersistentStores { description, error in
                if let error = error {
                    fatalError("Unable to load persistent stores: \(error)")
                }
            }
            return container
        }
        IoC.shared.registerLazySingleton(GitHubRepository.self) { GitHubRepositoryImpl() }
        
        IoC.shared.registerLazySingleton(ExecuteCommand.self) { ExecuteCommandImpl() }
        IoC.shared.registerLazySingleton(GetCommands.self) { GetCommandsImpl() }
        IoC.shared.registerLazySingleton(AddComand.self) { AddCommandImpl() }
        IoC.shared.registerLazySingleton(GetGroups.self) { GetGroupsImpl() }
        IoC.shared.registerLazySingleton(DeleteCommand.self) { DeleteCommandImpl() }
        IoC.shared.registerLazySingleton(EditCommand.self) { EditCommandImpl() }
        
        IoC.shared.registerLazySingleton(GetNewestRelease.self) { GetNewestReleaseImpl() }
        IoC.shared.registerLazySingleton(GetReleaseUrl.self) { GetReleaseUrlImpl() }
        IoC.shared.registerLazySingleton(IsNewVersionAvailable.self) { IsNewVersionAvailableImpl() }
        IoC.shared.registerLazySingleton(AppConfig.self) { AppConfigImpl() }
       
    }
}
