//
//  NightscoutAPISettingsViewController.swift
//  NightscoutRemoteCGM
//
//  Created by Ivan Valkou on 21.10.2019.
//  Copyright © 2019 Ivan Valkou. All rights reserved.
//

import SwiftUI
import HealthKit
import LoopKit
import LoopKitUI
import Combine

public final class NightscoutAPISettingsViewController: UIHostingController<SettingsView>, CompletionNotifying {
    
    public var completionDelegate: CompletionDelegate?

    public let cgmManager: NightscoutRemoteCGM

    public let displayGlucosePreference: DisplayGlucosePreference

    private var viewModel: SettingsViewModel

    private var lifetime: AnyCancellable?

    public init(cgmManager: NightscoutRemoteCGM, displayGlucosePreference: DisplayGlucosePreference) {
        self.cgmManager = cgmManager
        self.displayGlucosePreference = displayGlucosePreference
        self.viewModel = SettingsViewModel(nightscoutService: cgmManager.nightscoutService)
        let view = SettingsView(viewModel: self.viewModel)
        super.init(rootView: view)

        subscribeOnChanges()
    }

    private func subscribeOnChanges() {
        let onClose = viewModel.onClose
            .sink { [weak self] in
                guard let self = self else { return }
                self.completionDelegate?.completionNotifyingDidComplete(self)
                self.dismiss(animated: true)
            }

        let onDelete = viewModel.onDelete
            .sink { [weak self] in
                guard let self = self else { return }
                self.cgmManager.notifyDelegateOfDeletion {
                    DispatchQueue.main.async {
                        self.completionDelegate?.completionNotifyingDidComplete(self)
                        self.dismiss(animated: true)
                    }
                }
            }

        lifetime = AnyCancellable {
            onClose.cancel()
            onDelete.cancel()
        }
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
