# Architecture

Viably follows a layered **View → ViewModel → Service → Model** pattern. Each layer has a single responsibility and only talks to the layer directly below it.

---

## The 4 Layers

```
View
  └── owns ViewModel (@StateObject)
        └── calls Services (async functions)
              └── decode into Models (Codable structs)
```

---

## Models

Pure data structs that mirror database rows. They conform to `Codable` so Supabase can decode JSON responses directly into them. No logic lives here.

```swift
struct Habit: Codable, Identifiable {
    let id: UUID
    var name: String
    var isMVD: Bool
    var streakCount: Int
}
```

---

## Services

Stateless structs (or enums) that own all Supabase interaction. Each function returns a Model or array of Models. In plain english, they fetch data from Supabase and convert them into Swift format to be used.

```swift
struct HabitService {
    static func fetchAll(for userID: UUID) async throws -> [Habit] {
        try await supabase
            .from("habits")
            .select()
            .eq("user_id", value: userID)
            .execute()
            .value
    }
}
```

---

## ViewModels

`@MainActor` `ObservableObject` classes that hold UI state and coordinate service calls. They translate async results into `@Published` properties the View can bind to, and handle loading/error states.

```swift
@MainActor
class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var isLoading = false

    func loadHabits(for userID: UUID) async {
        isLoading = true
        defer { isLoading = false }
        habits = (try? await HabitService.fetchAll(for: userID)) ?? []
    }
}
```

---

## Views

Pure SwiftUI — no business logic, no direct Supabase calls. Each view owns its ViewModel via `@StateObject` and calls ViewModel methods in response to user actions.

```swift
struct HabitListView: View {
    @StateObject private var viewModel = HabitListViewModel()

    var body: some View {
        List(viewModel.habits) { habit in
            HabitRow(habit: habit)
        }
        .task { await viewModel.loadHabits(for: currentUserID) }
    }
}
```

---

## Data Flow Summary

User action → View calls ViewModel method → ViewModel calls Service → Service queries Supabase → decoded Model flows back up → ViewModel updates `@Published` state → View re-renders.
