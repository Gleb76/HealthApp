
import SwiftUI

struct HomeView: View {
    
    @State var calories: Int = 123
    @State var active: Int = 10
    @State var stand: Int = 8
    
    var body: some View {
        ScrollView(showsIndicators: false) {
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
        }
    }
}

#Preview {
    HomeView()
}
