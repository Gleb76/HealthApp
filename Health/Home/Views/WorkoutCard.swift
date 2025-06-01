
import SwiftUI


struct WorkoutCardView: View {
    @State var workout: Workout
    
     var body: some View {
         HStack {
             Image(systemName: workout.image)
                 .resizable()
                 .scaledToFit()
                 .frame(width: 48, height: 48)
                 .foregroundColor(workout.tintColor)
                 .padding()
                 .background(.gray.opacity(0.1))
                 .clipShape(RoundedRectangle(cornerRadius: 19))
             VStack(spacing: 16) {
                 HStack {
                     Text(workout.title)
                         .font(.title3)
                         .bold()
                     
                     Spacer()
    
                     Text(workout.duration)
                 }
                 HStack {
                     Text(workout.date)
                     Spacer()
                     Text(workout.calories)
                 }
             }
         }
         .padding(.horizontal)
    }
}

#Preview {
    WorkoutCardView(workout: Workout(id: 0, title: "Runnings", image: "figure.run", tintColor: .cyan, duration: "23 mins", date: "May 31", calories: "512"))
}
