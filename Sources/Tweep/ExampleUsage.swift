func main() async throws {
    let client = Twitter(
        consumerKey: "**********",
        consumerSecret: "**********",
        accessTokenKey: "**********",
        accessTokenSecret: "**********"
    )

    struct Tweet: Decodable {
        struct Data: Decodable {
            let author_id: String
            let created_at: String
            let id: String
            let text: String
        }
        
        struct Includes: Decodable {
            struct User: Decodable {
                let created_at: String
                let id: String
                let name: String
                let username: String
            }
            
            let users: [User]
        }
        
        let data: [Tweet.Data]
        let includes: Includes
    }

    let tweet: Tweet = try await client.get(
        "tweets",
        queryItems: ["ids": ["1228393702244134912"]]
    )
    
    print(tweet)
}
