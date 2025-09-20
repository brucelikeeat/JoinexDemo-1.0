import SwiftUI

struct DateTimeDurationSheet: View {
    @Binding var selectedDate: Date
    @Binding var selectedDuration: Int
    @State private var durationText: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Drag indicator
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            // Title
            Text("Schedule Event")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            // Date and Time Row
            HStack {
                Text("Date & Time")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                DatePicker("", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(Color.royalBlue)
            }
            .padding(.horizontal)
            
            // Duration Row
            HStack {
                Text("Duration")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                HStack(spacing: 8) {
                    TextField("Minutes", text: $durationText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .onChange(of: durationText) { _, newValue in
                            if let duration = Int(newValue), duration > 0 {
                                selectedDuration = duration
                            }
                        }
                    
                    Text("minutes")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            Spacer(minLength: 8)
        }
        .padding(.bottom, 12)
        .background(Color.white)
        .onAppear {
            durationText = "\(selectedDuration)"
        }
    }
} 