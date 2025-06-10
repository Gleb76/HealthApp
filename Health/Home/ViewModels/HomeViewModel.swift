import SwiftUI
import HealthKit

class HomeViewModel: ObservableObject {
    @Published var calories: Int = 0
    @Published var activeMinutes: Int = 0
    @Published var standHours: Int = 0
    @Published var isLoading: Bool = true
    @Published var error: HealthKitError?
    
    @Published var activities: [Activity] = []
    @Published var workouts: [Workout] = []
    
    private let healthManager = HealthDataManager.shared
    
    init() {
        fetchHealthData()
        setupMockData()
    }
    
    func fetchHealthData() {
        isLoading = true
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        healthManager.fetchTodayCaloriesBurned { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let calories):
                    self?.calories = Int(calories)
                case .failure(let error):
                    self?.error = error as? HealthKitError
                }
                dispatchGroup.leave()
            }
        }
        
        // Запрос времени активности
        dispatchGroup.enter()
        healthManager.fetchTodayExerciseTime { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let seconds):
                    self?.activeMinutes = Int(seconds / 60)
                case .failure(let error):
                    self?.error = error as? HealthKitError
                }
                dispatchGroup.leave()
            }
        }
        
        // Запрос часов стояния
        dispatchGroup.enter()
        healthManager.fetchTodayStandHours { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let hours):
                    self?.standHours = Int(hours)
                case .failure(let error):
                    self?.error = error as? HealthKitError
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.isLoading = false
            self?.updateActivities()
        }
    }
    
    private func updateActivities() {
        activities = [
            Activity(
                id: 0,
                title: "Active Calories",
                subtitle: "Goal: \(formatCalories(1000))",
                image: "flame",
                tintColor: .orange,
                amount: formatCalories(calories)
            ),
            Activity(
                id: 1,
                title: "Exercise Time",
                subtitle: "Goal: 30 mins",
                image: "figure.walk",
                tintColor: .green,
                amount: "\(activeMinutes) mins"
            ),
            Activity(
                id: 2,
                title: "Stand Hours",
                subtitle: "Goal: 12 hours",
                image: "figure.stand",
                tintColor: .blue,
                amount: "\(standHours) hrs"
            ),
            Activity(
                id: 3,
                title: "Steps",
                subtitle: "Goal: 10,000",
                image: "figure.walk",
                tintColor: .purple,
                amount: "9,812" // Можно добавить запрос шагов из HealthKit
            )
        ]
    }
    
    private func setupMockData() {
        workouts = [
            Workout(
                id: 0,
                title: "Strength training",
                image: "dumbbell",
                tintColor: .cyan,
                duration: "23 mins",
                date: Date().formatted(date: .abbreviated, time: .omitted),
                calories: "512"
            ),
            Workout(
                id: 1,
                title: "Running",
                image: "figure.run",
                tintColor: .red,
                duration: "32 mins",
                date: Date().formatted(date: .abbreviated, time: .omitted),
                calories: "412"
            ),
            Workout(
                id: 2,
                title: "Cycling",
                image: "figure.outdoor.cycle",
                tintColor: .purple,
                duration: "40 mins",
                date: Date().formatted(date: .abbreviated, time: .omitted),
                calories: "612"
            ),
            Workout(
                id: 3,
                title: "Yoga",
                image: "figure.mind.and.body",
                tintColor: .indigo,
                duration: "60 mins",
                date: Date().formatted(date: .abbreviated, time: .omitted),
                calories: "312"
            )
        ]
    }
    
    private func formatCalories(_ calories: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: calories)) ?? "0"
    }
    
    func refreshData() {
        fetchHealthData()
    }
    
    func showMoreActivities() {
        // Здесь может быть навигация или отображение детальной информации
        print("Showing more activities")
    }
}
