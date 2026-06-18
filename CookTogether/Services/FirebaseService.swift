import Foundation
import FirebaseDatabase

// MARK: - Room Model
struct Room: Codable {
    let roomCode: String
    let creatorName: String
    var partnerName: String?
    let createdAt: TimeInterval
    var status: RoomStatus
    
    enum RoomStatus: String, Codable {
        case waiting
        case ready
        case cooking
        case complete
    }
}

// MARK: - Firebase Service
class FirebaseService {
    static let shared = FirebaseService()
    private let database = Database.database().reference()
    
    private init() {}
    
    // MARK: - Room Operations
    
    func generateRoomCode() -> String {
        let code = String(format: "%04d", Int.random(in: 0...9999))
        return code
    }
    
    func createRoom(creatorName: String, completion: @escaping (Result<String, Error>) -> Void) {
        let roomCode = generateRoomCode()
        checkRoomExists(code: roomCode) { exists in
            if exists {
                // Code collision - try again
                self.createRoom(creatorName: creatorName, completion: completion)
            } else {
                let room = Room(
                    roomCode: roomCode,
                    creatorName: creatorName,
                    partnerName: nil,
                    createdAt: Date().timeIntervalSince1970,
                    status: .waiting
                )
                
                self.saveRoom(room) { result in
                    completion(result.map { roomCode })
                }
            }
        }
    }
    
    func checkRoomExists(code: String, completion: @escaping (Bool) -> Void) {
        database.child("rooms").child(code).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
    
    func joinRoom(code: String, partnerName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        checkRoomExists(code: code) { [weak self] exists in
            guard let self = self else { return }
            
            if !exists {
                completion(.failure(NSError(domain: "Room not found", code: 404)))
                return
            }
            
            // Update room with partner name
            self.database.child("rooms").child(code).child("partnerName").setValue(partnerName) { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    // Update status to ready
                    self.database.child("rooms").child(code).child("status").setValue("ready") { error, _ in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            }
        }
    }
    
    private func saveRoom(_ room: Room, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let data = try? JSONEncoder().encode(room),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            completion(.failure(NSError(domain: "Encoding Error", code: -1)))
            return
        }
        
        database.child("rooms").child(room.roomCode).setValue(dict) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
