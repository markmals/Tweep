import Foundation

public struct TwitterError: LocalizedError {
    public let errorDescription: String?
    
    public init(_ errorDescription: String?) {
        self.errorDescription = errorDescription
    }
}

extension TwitterError: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.errorDescription = value
    }
}
