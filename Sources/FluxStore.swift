import Foundation

class FluxStore {
    var dispatchId: Int?
    var currentId: Int = 0
    var listeners: Dictionary<Int, (ChangeEvent) -> Void>

    init() {
        currentId = 0
        listeners = [:]
        dispatchId = nil
    }

    // Remove any references
    func detachStore() {
        if let id = dispatchId {
            Dispatcher.sharedInstance.unregister(id)
        }

        listeners = [:]
        dispatchId = nil
    }

    func removeListener(id: Int) {
        listeners.removeValueForKey(id)
    }

    func emit(event: ChangeEvent) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            for (_, listener) in self.listeners {
                listener(event)
            }
        })
    }


    func addListener(callback: (ChangeEvent) -> Void) -> Int {
        let returnId = self.currentId
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.listeners[returnId] = callback
            self.currentId++
        })
        return returnId
    }
}
