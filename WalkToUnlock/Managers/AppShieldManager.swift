import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings
import SwiftUI
import Combine

struct EquatableFamilyActivitySelection: Equatable {
    let selection: FamilyActivitySelection

    static func == (lhs: EquatableFamilyActivitySelection, rhs: EquatableFamilyActivitySelection) -> Bool {
        lhs.selection.applicationTokens == rhs.selection.applicationTokens &&
        lhs.selection.categoryTokens == rhs.selection.categoryTokens &&
        lhs.selection.webDomainTokens == rhs.selection.webDomainTokens
    }
}

class AppShieldManager: ObservableObject {
    static let shared = AppShieldManager()
    
    private let store: ManagedSettingsStore
    @Published private(set) var activitySelection: FamilyActivitySelection
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published private(set) var equatableActivitySelection: EquatableFamilyActivitySelection
    @Published private(set) var areAppsUnblocked: Bool

    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let unblockStatusKey = "appsUnblockedToday"
    
    func setAppsUnblocked(_ value: Bool) {
            areAppsUnblocked = value
            userDefaults.set(value, forKey: unblockStatusKey)
    }

    private init() {
        store = ManagedSettingsStore()
        
        let loadedSelection: FamilyActivitySelection
        if let savedData = UserDefaults.standard.data(forKey: "SavedActivitySelection"),
           let decodedSelection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: savedData) {
            loadedSelection = decodedSelection
        } else {
            loadedSelection = FamilyActivitySelection()
        }
        
        self.activitySelection = loadedSelection
        self.equatableActivitySelection = EquatableFamilyActivitySelection(selection: loadedSelection)
        self.areAppsUnblocked = UserDefaults.standard.bool(forKey: unblockStatusKey)
        
        setupObservation()
    }
    
    private func setupObservation() {
        AuthorizationCenter.shared.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newStatus in
                self?.authorizationStatus = newStatus
            }
            .store(in: &cancellables)
        
        updateAuthorizationStatus()
    }
    
    private func updateAuthorizationStatus() {
        DispatchQueue.main.async { [weak self] in
            self?.authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        }
    }
    
    func checkAndRequestAuthorization() async {
        updateAuthorizationStatus()
        if authorizationStatus != .approved {
            do {
                try await requestAuthorization()
                await MainActor.run {
                    updateAuthorizationStatus()
                }
            } catch {
                print("Failed to request authorization: \(error)")
            }
        }
    }
    
    func requestAuthorization() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
    }
    
    func setShieldRestrictions() {
        store.shield.applications = activitySelection.applicationTokens.isEmpty ? nil : activitySelection.applicationTokens
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(activitySelection.categoryTokens, except: Set())
        store.shield.webDomains = activitySelection.webDomainTokens
        store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.specific(activitySelection.categoryTokens, except: Set())
        setAppsUnblocked(false)
        saveActivitySelection()
    }
        
    func clearShieldRestrictions() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        store.shield.webDomainCategories = nil
        setAppsUnblocked(true)
//        saveActivitySelection()
    }
    
    func resetShieldRestrictions() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        store.shield.webDomainCategories = nil
        setAppsUnblocked(true)
        resetActivitySelection()
    }
        
    func initiateMonitoring(startTime: Date, endTime: Date) throws {
        let scheduleStart = Calendar.current.dateComponents([.hour, .minute], from: startTime)
        let scheduleEnd = Calendar.current.dateComponents([.hour, .minute], from: endTime)
        let schedule = DeviceActivitySchedule(intervalStart: scheduleStart,
                                              intervalEnd: scheduleEnd,
                                              repeats: true)
        let center = DeviceActivityCenter()
        try center.startMonitoring(.daily, during: schedule)
    }
    
    func stopMonitoring() {
        let center = DeviceActivityCenter()
        center.stopMonitoring([.daily])
    }
    
    func resetActivitySelection() {
        let emptySelection = FamilyActivitySelection()
        activitySelection = emptySelection
        equatableActivitySelection = EquatableFamilyActivitySelection(selection: emptySelection)
        saveActivitySelection()
        objectWillChange.send()
    }
    
    func setActivitySelection(_ selection: FamilyActivitySelection) {
        let newEquatableSelection = EquatableFamilyActivitySelection(selection: selection)
        if equatableActivitySelection != newEquatableSelection {
            objectWillChange.send()
            activitySelection = selection
            equatableActivitySelection = newEquatableSelection
            saveActivitySelection()
            print("AppShieldManager.setActivitySelection—Activity selection updated and saved. Number of selected apps: \(selection.applicationTokens.count)")
        }
    }

    
    func displayFamilyActivityPicker(title: String = "",
                                     headerText: String = "",
                                     footerText: String = "") -> some View {
        FamilyActivityPickerView(activitySelection: Binding(
            get: { self.activitySelection },
            set: { self.setActivitySelection($0) }
        ),
        title: title,
        headerText: headerText,
        footerText: footerText)
    }
    
    private func saveActivitySelection() {
        if let encoded = try? JSONEncoder().encode(activitySelection) {
            UserDefaults.standard.set(encoded, forKey: "SavedActivitySelection")
        }
    }

    private func loadActivitySelection() {
        if let savedSelection = UserDefaults.standard.data(forKey: "SavedActivitySelection"),
           let decodedSelection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: savedSelection) {
            activitySelection = decodedSelection
            equatableActivitySelection = EquatableFamilyActivitySelection(selection: decodedSelection)
        }
    }
}

extension DeviceActivityName {
    static let daily = Self("daily")
}
