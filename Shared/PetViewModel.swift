import Foundation
import Combine

class PetViewModel: ObservableObject {
    @Published var pet: Pet
    @Published var currentAchievements: [Achievement] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let saveKey = "savedPet"
    
    init() {
        if let savedData = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode(Pet.self, from: savedData) {
            self.pet = decoded
        } else {
            self.pet = Pet()
        }
        
        setupTimer()
        checkAchievements()
    }
    
    private func setupTimer() {
        // 每分钟检查一次饿晕状态
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkDizzy()
            }
            .store(in: &cancellables)
    }
    
    private func checkDizzy() {
        var updatedPet = pet
        updatedPet.checkDizzyState()
        pet = updatedPet
        save()
        checkAchievements()
    }
    
    func feed(calories: Int) {
        var updatedPet = pet
        updatedPet.feed(calories: calories)
        pet = updatedPet
        save()
        checkAchievements()
    }
    
    func exercise(calories: Int) {
        var updatedPet = pet
        updatedPet.exercise(calories: calories)
        pet = updatedPet
        save()
        checkAchievements()
    }
    
    func checkAchievements() {
        let achievementSystem = AchievementSystem(pet: pet)
        let newAchievements = achievementSystem.checkAchievements()
        
        // 更新宠物已解锁成就
        var updatedPet = pet
        for achievement in newAchievements {
            if !updatedPet.unlockedAchievements.contains(achievement.id) {
                updatedPet.unlockedAchievements.append(achievement.id)
            }
        }
        pet = updatedPet
        currentAchievements = newAchievements
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(pet) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    // 获取饿晕状态描述
    var dizzyDescription: String {
        if pet.state == .dizzy {
            return "宠物饿晕了！快喂食恢复吧~"
        }
        return ""
    }
    
    // 获取状态颜色
    var stateColor: String {
        switch pet.state {
        case .normal: return "green"
        case .happy: return "yellow"
        case .sad: return "blue"
        case .hungry: return "orange"
        case .dizzy: return "gray"
        case .sleeping: return "purple"
        case .exercising: return "red"
        }
    }
}
