import SwiftUI
import Charts
import HealthKit

struct ChartsView: View {
    @StateObject private var viewModel = ChartsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                caloriesChart
                activityChart
                standHoursChart
                stepsChart
            }
            .padding()
        }
        .navigationTitle("Activity Charts")
        .onAppear {
            viewModel.fetchHealthData()
        }
    }
    
    private var caloriesChart: some View {
        chartContainer(
            title: "Calories Burned",
            data: viewModel.weeklyCalories,
            chartContent: { items in
                Chart(items) { item in
                    BarMark(
                        x: .value("Day", item.date, unit: .day),
                        y: .value("Calories", item.value)
                    )
                    .foregroundStyle(by: .value("Day", item.date))
                    .annotation(position: .top) {
                        Text("\(Int(item.value))")
                            .font(.caption2)
                    }
                }
                .chartForegroundStyleScale([Date(): .orange])
            }
        )
    }
    
    private var activityChart: some View {
        chartContainer(
            title: "Exercise Minutes",
            data: viewModel.weeklyActivity,
            chartContent: { items in
                Chart(items) { item in
                    LineMark(
                        x: .value("Day", item.date, unit: .day),
                        y: .value("Minutes", item.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.green)
                    .annotation(position: .top) {
                        Text("\(Int(item.value))")
                            .font(.caption2)
                    }
                }
            }
        )
    }
    
    private var standHoursChart: some View {
        chartContainer(
            title: "Stand Hours",
            data: viewModel.weeklyStandHours,
            chartContent: { items in
                Chart(items) { item in
                    AreaMark(
                        x: .value("Day", item.date, unit: .day),
                        y: .value("Hours", item.value)
                    )
                    .foregroundStyle(.blue.opacity(0.3))
                    
                    LineMark(
                        x: .value("Day", item.date, unit: .day),
                        y: .value("Hours", item.value)
                    )
                    .foregroundStyle(.blue)
                    .annotation(position: .top) {
                        Text("\(Int(item.value))")
                            .font(.caption2)
                    }
                }
            }
        )
    }
    
    private var stepsChart: some View {
        chartContainer(
            title: "Daily Steps",
            data: viewModel.weeklySteps,
            chartContent: { items in
                Chart {
                    ForEach(items) { item in
                        BarMark(
                            x: .value("Day", item.date, unit: .day),
                            y: .value("Steps", item.value)
                        )
                        .foregroundStyle(.purple.opacity(0.5))
                        
                        RuleMark(
                            y: .value("Goal", 10000)
                        )
                        .foregroundStyle(.red)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    }
                }
            }
        )
    }
    
    private func chartContainer<Content: View>(
        title: String,
        data: [HealthDataPoint],
        @ViewBuilder chartContent: @escaping ([HealthDataPoint]) -> Content
    ) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            
            if data.isEmpty {
                Text("No data available.")
                    .foregroundColor(.gray)
                    .frame(height: 100)
            } else if data.count < 2 {
                Text("Insufficient data points.")
                    .foregroundColor(.gray)
                    .frame(height: 100)
            } else {
                chartContent(data)
                    .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

class ChartsViewModel: ObservableObject {
    @Published var weeklyCalories: [HealthDataPoint] = []
    @Published var weeklyActivity: [HealthDataPoint] = []
    @Published var weeklyStandHours: [HealthDataPoint] = []
    @Published var weeklySteps: [HealthDataPoint] = []
    @Published var isLoading = false
    @Published var error: HealthKitError?
    
    private let healthManager = HealthDataManager.shared
    
    func fetchHealthData() {
        isLoading = true
        generateMockData()
    }
    
    private func generateMockData() {
        let calendar = Calendar.current
        let now = Date()
        var dates: [Date] = []
        
        // Создаем массив дат за последние 7 дней
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                dates.append(calendar.startOfDay(for: date))
            }
        }
        
        dates.sort { $0 < $1 }
        
        // Генерация случайных данных для каждого типа
        weeklyCalories = dates.map { date in
            let value = Double.random(in: 200...600)
            return HealthDataPoint(date: date, value: value)
        }
        
        weeklyActivity = dates.map { date in
            let value = Double.random(in: 5...120)
            return HealthDataPoint(date: date, value: value)
        }
        
        weeklyStandHours = dates.map { date in
            let value = Double.random(in: 0...12)
            return HealthDataPoint(date: date, value: value)
        }
        
        weeklySteps = dates.map { date in
            let value = Double.random(in: 2000...15000)
            return HealthDataPoint(date: date, value: value)
        }
        
        isLoading = false
    }
    
}

struct HealthDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    var value: Double
}


struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsView()
    }
}
