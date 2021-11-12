import Foundation

public struct Twitter {
    public let credentials: Credentials
    private let decoder = JSONDecoder()
    
    public init(
        consumerKey: String?,
        consumerSecret: String?,
        bearerToken: String?
    ) {
        self.credentials = Credentials(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            bearerToken: bearerToken
        )
    }
    
    public init(
        consumerKey: String,
        consumerSecret: String,
        accessTokenKey: String,
        accessTokenSecret: String
    ) {
        self.credentials = Credentials(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            accessTokenKey: accessTokenKey,
            accessTokenSecret: accessTokenSecret
        )
    }
    
    private func url(for endpoint: String, with queryItems: [String: [String]]?) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.twitter.com"
        components.path = "/2/\(endpoint)"
        components.queryItems = queryItems?.map {
            URLQueryItem(name: $0, value: $1.joined(separator: ","))
        }
        
        return components.url!
    }
    
    private func fetch<Response: Decodable>(_ request: URLRequest) async throws -> Response {
        // TODO: Map to a TwitterError
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            // FIXME: Throw a better error
            throw URLError(.unknown)
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            // FIXME: Throw a better error
            throw URLError(.unknown)
        }
        
        return try decoder.decode(Response.self, from: data)
    }
        
    public func get<Response: Decodable>(
        _ endpoint: String,
        queryItems: [String: [String]]?
    ) async throws -> Response {
        var request = URLRequest(url: url(for: endpoint, with: queryItems))
        request.httpMethod = "GET"
        request.addValue(
            "Authorization",
            forHTTPHeaderField: try await credentials.authorizationHeader(
                url: url(for: endpoint, with: queryItems),
                request: .init(method: "GET")
            )
        )
        
        return try await fetch(request)
    }
    
    @discardableResult
    public func post<Response: Decodable, Body: Encodable>(
        _ endpoint: String,
        body: Body,
        queryItems: [String: [String]]?
    ) async throws -> Response {
        var request = URLRequest(url: url(for: endpoint, with: queryItems))
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(body)
        request.addValue(
            "Authorization",
            forHTTPHeaderField: try await credentials.authorizationHeader(
                url: url(for: endpoint, with: queryItems),
                request: .init(method: "POST", body: body)
            )
        )
        
        return try await fetch(request)
    }
    
    @discardableResult
    public func delete<Response: Decodable>(
        _ endpoint: String,
        queryItems: [String: [String]]?
    ) async throws -> Response {
        var request = URLRequest(url: url(for: endpoint, with: queryItems))
        request.httpMethod = "DELETE"
        request.addValue(
            "Authorization",
            forHTTPHeaderField: try await credentials.authorizationHeader(
                url: url(for: endpoint, with: queryItems),
                request: .init(method: "DELETE")
            )
        )
        
        return try await fetch(request)
    }
    
    // TODO: Add `stream` method
}
