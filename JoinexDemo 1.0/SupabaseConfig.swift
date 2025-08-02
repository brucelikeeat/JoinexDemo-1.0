import Foundation
import Supabase

// Replace these with your actual Supabase project details
// You can find these in your Supabase project dashboard
struct SupabaseConfig {
    static let supabaseURL = "https://ujmaeicdzaobfhymzlez.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVqbWFlaWNkemFvYmZoeW16bGV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM4NTIzMjgsImV4cCI6MjA2OTQyODMyOH0.vDHwzL-9FKM-jrUxMV1EVxm7_edd-kPLHXEyGuT6tlY"
    
    // Create the Supabase client
    static let client = SupabaseClient(
        supabaseURL: URL(string: supabaseURL)!,
        supabaseKey: supabaseAnonKey
    )
}

