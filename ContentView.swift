import SwiftUI

struct ContentView: View {
    @StateObject private var store  = SubStore()
    @State private var showAdd      = false
    @State private var showSettings = false
    @State private var editMode     = EditMode.inactive

    var body: some View {
        NavigationView {
            List {
                Section {
                    HeaderView(
                        monthlyTotal: store.monthlyTotal,
                        yearlyTotal:  store.yearlyTotal,
                        breakdown:    store.categoryBreakdown,
                        subCount:     store.subscriptions.count,
                        renewingSoon: store.renewingSoon
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color(.systemGroupedBackground))
                    .listRowSeparator(.hidden)
                }

                Section {
                    if store.subscriptions.isEmpty {
                        VStack(spacing: 10) {
                            Text("📋").font(.system(size: 44))
                            Text("No Subscriptions")
                                .font(.system(size: 17, weight: .semibold))
                            Text("Tap + to add your first one")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .listRowBackground(Color(.systemGroupedBackground))
                        .listRowSeparator(.hidden)
                    } else {
                        ForEach(store.subscriptions) { sub in
                            SubRowView(sub: sub)
                        }
                        .onDelete { store.delete(at: $0) }
                        .onMove  { store.move(from: $0, to: $1) }
                    }
                } header: {
                    if !store.subscriptions.isEmpty {
                        Text("\(store.subscriptions.count) Subscription\(store.subscriptions.count != 1 ? "s" : "")")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .environment(\.editMode, $editMode)
            .navigationTitle("Subscriptions101")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape").font(.system(size: 17))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        if !store.subscriptions.isEmpty {
                            EditButton()
                        }
                        if editMode == .inactive {
                            Button { showAdd = true } label: {
                                Image(systemName: "plus.circle.fill").font(.system(size: 22))
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddSubSheet { sub in withAnimation { store.add(sub) } }
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet()
            }
        }
    }
}

#Preview {
    ContentView()
}
