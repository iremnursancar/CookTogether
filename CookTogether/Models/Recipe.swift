import Foundation

struct Recipe: Codable, Identifiable {
    let id: String
    let name: String
    let imageURL: String
    let imageName: String
    let cookingTime: Int
    let difficulty: String
    let description: String
    let ingredients: [String]
    let steps: [RecipeStep]
}

struct RecipeStep: Codable, Identifiable {
    let id: String
    let description: String
    let assignedTo: String
    let duration: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, description, assignedTo, duration
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        description = try container.decode(String.self, forKey: .description)
        assignedTo = try container.decode(String.self, forKey: .assignedTo)
        
        if let durationInt = try? container.decode(Int.self, forKey: .duration) {
            duration = durationInt
        } else if let durationString = try? container.decode(String.self, forKey: .duration),
                  durationString != "null" {
            duration = Int(durationString)
        } else {
            duration = nil
        }
    }
}
