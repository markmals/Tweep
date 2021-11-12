import Foundation

enum Bearer {
    fileprivate struct Body: Decodable {
        let errors: [Bearer.Error]?
        let title: String?
        let type: String?
        let detail: String?
        
        let tokenType: String?
        let accessToken: String?
        
        enum CodingKeys: String, CodingKey {
            case errors
            case title
            case type
            case detail
            
            case tokenType = "token_type"
            case accessToken = "access_token"
        }
    }
    
    fileprivate struct Error: Decodable {
        let message: String
    }
    
    static func generateToken(consumerKey: String, consumerSecret: String) async throws -> String {
        let tokenURL = URL(string: "https://api.twitter.com/oauth2/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)
        let base64String = "\(consumerKey):\(consumerSecret)"
            .data(using: .utf8)!
            .base64EncodedString()
        request.addValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        request.addValue(
            "application/x-www-form-urlencoded;charset=UTF-8",
            forHTTPHeaderField: "Content-Type"
        )
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let body = try JSONDecoder().decode(Body.self, from: data)
        
        guard body.errors == nil else {
            throw TwitterError(body)
        }
        
        guard body.tokenType == "bearer" else {
            throw TwitterError.unexpectedReply(with: body.tokenType)
        }
        
        guard let accessToken = body.accessToken else {
            throw TwitterError.missingAccessToken
        }
        
        return accessToken
    }
}

fileprivate extension TwitterError {
    init(_ body: Bearer.Body) {
        // TODO: Handle the nullables better than with !
        self.init(
            """
            \(body.title!): \(body.errors![0].message)
            \(body.type!) \(body.detail!)
            """
        )
    }
    
    static let missingAccessToken: Self = "Could not find access token"

    static func unexpectedReply(with tokenType: String?) -> Self {
        .init(
            """
            Unexpected reply from Twitter upon obtaining bearer token:
            Expected 'bearer' but found '\(tokenType ?? "")'
            """
        )
    }
}
