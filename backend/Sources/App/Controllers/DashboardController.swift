import Vapor

final class DashboardController {
    private let service: DashboardServiceProtocol

    init(service: DashboardServiceProtocol = DashboardService()) {
        self.service = service
    }

    func summary(_ req: Request) async throws -> DashboardSummaryDTO {
        let user = try req.authUser
        return try await service.getSummary(req, user: user)
    }
}
