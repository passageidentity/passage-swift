import Foundation

public protocol PassageError: Error, Equatable, LocalizedError {
    static func convert(error: Error) -> Self
    var errorDescription: String { get }
}

struct PassageErrorData: Codable {
    let code: String
    let error: String
    
    static func getData(from errorResponse: ErrorResponse) -> (Int, PassageErrorData)? {
        guard
            case let ErrorResponse.error(statusCode, data?, _, _) = errorResponse,
            let errorData = try? JSONDecoder().decode(PassageErrorData.self, from: data)
        else {
            return nil
        }
        return (statusCode, errorData)
    }
}
