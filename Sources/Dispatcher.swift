// The one and only dispatcher which routes actions to the stores
class Dispatcher {
    var currentId: Int = 0
    var listeners: Dictionary<Int, (Action) -> Void> = [:]

    func register(callback: (Action) -> Void) -> Int {
        let returnId = self.currentId++
        self.listeners[returnId] = callback
        return returnId
    }

    func unregister(id: Int) {
        self.listeners.removeValueForKey(id)
    }

    func dispatch(payload: Action) {
        for (_, listener) in self.listeners {
            listener(payload)
        }
    }

    func reset() {
        listeners = [:]
    }

    private init () {

    }

    static let sharedInstance = Dispatcher()

}
