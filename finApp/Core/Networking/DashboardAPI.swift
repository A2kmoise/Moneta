import Foundation

final class DashboardAPI {
    private let client: APIClient
    
    init(client: APIClient = .shared) {
        self.client = client
    }
    
    func getDashboardSummary() async throws -> DashboardSummaryDTO {
        try await client.request("/dashboard/summary")
    }
}
