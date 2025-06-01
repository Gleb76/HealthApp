
import SwiftUI

struct HomeView: View {
    
    @State var calories: Int = 123
    @State var active: Int = 10
    @State var stand: Int = 8
    
    var mockActivities = [
        Activity(id: 0, title: "Today steps", subtitle: "Goal 12,000", image: "figure.walk", tintColor: .green, amount: "9812"),
        Activity(id: 1, title: "Today steps", subtitle: "Goal 12,000", image: "figure.walk", tintColor: .red, amount: "9812"),
        Activity(id: 2, title: "Today steps", subtitle: "Goal 12,000", image: "figure.walk", tintColor: .blue, amount: "9812"),
        Activity(id: 3, title: "Today steps", subtitle: "Goal 12,000", image: "figure.run", tintColor: .purple, amount: "10,812")
    ]
    
    var mockWorkouts = [
        Workout(id: 0, title: "Strength training", image: "figure.run", tintColor: .cyan, duration: "23 mins", date: "May 31", calories: "512"),
        Workout(id: 1, title: "Runnings", image: "figure.run", tintColor: .red, duration: "3 mins", date: "May 31", calories: "512"),
        Workout(id: 2, title: "Runnings", image: "figure.run", tintColor: .purple, duration: "40 mins", date: "May 31", calories: "512"),
        Workout(id: 3, title: "Runnings", image: "figure.run", tintColor: .cyan, duration: "1 mins", date: "May 31", calories: "512")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text("Welcome")
                        .font(.largeTitle)
                        .padding()
                    
                    HStack {
                        
                        Spacer()
                        
                        VStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Calories")
                                    .font(.callout)
                                    .bold()
                                    .foregroundColor(.red)
                                
                                Text("123 kcal")
                                    .bold()
                            }
                            .padding(.bottom)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Active")
                                    .font(.callout)
                                    .bold()
                                    .foregroundColor(.red)
                                
                                Text("52 mins")
                                    .bold()
                            }
                            .padding(.bottom)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Stand")
                                    .font(.callout)
                                    .bold()
                                    .foregroundColor(.red)
                                
                                Text("8 hours")
                                    .bold()
                            }
                        }
                        
                        Spacer()
                        
                        ZStack {
                            ProgressCircleView(progress: $calories, goal: 600, color: .red)
                            ProgressCircleView(progress: $active, goal: 60, color: .green)
                                .padding(.all, 20)
                            ProgressCircleView(progress: $calories, goal: 12, color: .blue)
                                .padding(.all, 40)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding()
                    
                    HStack {
                        Text("Fitness Activity")
                            .font(.title2)
                        
                        Spacer()
                        
                        Button {
                            print("show more")
                        } label: {
                            Text("Show more")
                                .padding(.all, 10)
                                .background(.blue)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
                        ForEach(mockActivities, id: \.id) {activity in
                            ActivityCardView(activity: activity)
                            
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Recents Workouts")
                            .font(.title2)
                        
                        Spacer()
                        
                        NavigationLink {
                            EmptyView()
                        } label: {
                            Text("Show more")
                                .padding(.all, 10)
                                .background(.blue)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                   LazyVStack {
                       ForEach(mockWorkouts, id: \.id) { workout in
                           WorkoutCardView(workout: workout)
                       }
                    }
                   .padding(.bottom)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
