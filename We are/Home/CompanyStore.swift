// CompanyStore.swift
import SwiftUI
import Combine

@MainActor
final class CompanyStore: ObservableObject {
    @Published var companies: [Company] = Company.demoList
}
