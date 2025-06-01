
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var calories: Int = 123
    @Published var active: Int = 10
    @Published var stand: Int = 8
    
    @Published var mockActivities = [
        Activity(id: 0, title: "Today steps", subtitle: "Goal 12,000", image: "figure.walk", tintColor: .green, amount: "9812"),
        Activity(id: 1, title: "Today steps", subtitle: "Goal 12,000", image: "figure.walk", tintColor: .red, amount: "9812"),
        Activity(id: 2, title: "Today steps", subtitle: "Goal 12,000", image: "figure.walk", tintColor: .blue, amount: "9812"),
        Activity(id: 3, title: "Today steps", subtitle: "Goal 12,000", image: "figure.run", tintColor: .purple, amount: "10,812")
    ]
    
    @Published var mockWorkouts = [
        Workout(id: 0, title: "Strength training", image: "figure.run", tintColor: .cyan, duration: "23 mins", date: "May 31", calories: "512"),
        Workout(id: 1, title: "Runnings", image: "figure.run", tintColor: .red, duration: "3 mins", date: "May 31", calories: "512"),
        Workout(id: 2, title: "Runnings", image: "figure.run", tintColor: .purple, duration: "40 mins", date: "May 31", calories: "512"),
        Workout(id: 3, title: "Runnings", image: "figure.run", tintColor: .cyan, duration: "1 mins", date: "May 31", calories: "512")
    ]
    
    func showMoreActivities() {
        print("show more activities")
    }
}
