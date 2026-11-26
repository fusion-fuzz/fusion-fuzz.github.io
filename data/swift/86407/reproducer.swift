var globalStorage = [Int: [Int]]()

class Service {
    func run(data: [[String: Any]]) {
        for item in data {
        
            let innerList: [[String: Any]] = []
            
            for innerItem in innerList {
                if (item["Score"] as? Int ?? 0) != 0 {
                    
                    if !(innerItem["Flag"] as? Bool ?? false) {
                    }
                    
                    let queue: [Int] = []
                    for id in queue {
                        globalStorage[id, default: []].append(item["ID"] as! Int)
                    }
                }
            }
        }
    }
}

let s = Service()
s.run(data: [["Score": 10, "ID": 1]])
