access(all)
contract FLIXRegistry{
    /// Published
    ///
    /// The event that is emitted when a new FLIX is published to a Registry resource.
    ///
    access(all)
    event Published(id:String, cadenceBodyHash:String, alias:String, registry:Address, removeable:Bool)

    /// FLIXStatus
    ///
    /// Enum that represents the status of of FLIX
    ///
    access(all)
    enum FLIXStatus: UInt8 {
        pub case DRAFT
        pub case PUBLISHED
        pub case DEPRECATED
    }

    /// FLIX
    ///
    /// Struct that represents a FLIX
    ///
    access(all)
    struct FLIX {
        access(all) let id: String

        init(id: String) {
            self.id=id
        }
    }

    resource interface QueryableFLIX {

        access(all)
        fun resolve(cadenceBodyHash: String): &FLIX

        access(all)
        fun lookup(idOrAlias: String): &FLIX
    }

    resource interface Admin {

        /// Add the flix to the registry and add or update the alias to point to this flix
        access(all) 
        fun publish(alias:String, flix:FLIX)

        access(all)
        fun link(alias:String, id:String)

        access(all)
        fun unlink(alias:String)

        access(all)
        fun deprecate(alias:String, status:FLIXStatus)
    }

    resource interface Removeable {
        access(all)
        fun remove(flix:FLIX)
    }

    access(all)
    resource Registry: QueryableFLIX, Admin, Removeable {
        let flix: {String: FLIX}
        let aliasMap: {String: String}

        access(all)
        fun resolve(cadenceBodyHash: String): &FLIXRegistry.FLIX {
            panic("TODO")
        }

        access(all)
        fun lookup(idOrAlias: String): &FLIXRegistry.FLIX {
            panic("TODO")
        }

        access(all)
        fun publish(alias: String, flix: FLIXRegistry.FLIX) {
            self.flix[flix.id] = flix
            self.link(alias: alias, id: flix.id)

            emit Published(id: flix.id, cadenceBodyHash: "", alias: alias, registry: self.owner!.address, removeable: false)
        }

        access(all)
        fun link(alias: String, id: String) {
            self.aliasMap[alias] = id
        }

        access(all)
        fun unlink(alias: String) {
            panic("TODO")
        }

        access(all)
        fun deprecate(alias: String, status: FLIXRegistry.FLIXStatus) {
            panic("TODO")
        }
    
        access(all) fun remove(flix: FLIXRegistry.FLIX) {
            panic("TODO")
        }

        init() {
            self.flix = {}
            self.aliasMap = {}
        }
    }

    access(all)
    fun createRegistry(): @Registry {
        return <- create Registry()
    }

    //split on 0x123/<channel>/<aliasOrId>
    access(all)
    fun lookup(path:String) : &FLIX? {

        let paths = path.split(separator: "/")


        let address=  FLIXRegistry.stringToAddress(paths[0])
        let account = getAccount(address)

        let pp = PublicPath(identifier: paths[1])!
        let registry =account.capabilities.borrow<&{FLIXRegistry.QueryableFLIX}>(pp)!
        return registry.lookup(idOrAlias:paths[2])
    }

    access(all)
    fun lookupB(address:Address, path:PublicPath, aliasOrId:String) : &FLIX? {

        let account = getAccount(address)

        let registry =account.capabilities.borrow<&{FLIXRegistry.QueryableFLIX}>(path)!
        return registry.lookup(idOrAlias: aliasOrId)
    }

    access(all) fun stringToAddress(_ input:String): Address {
        var address=input
        if input.utf8[1] == 120 {
            address = input.slice(from: 2, upTo: input.length)
        }
        var r:UInt64 = 0
        var bytes = address.decodeHex()

        while bytes.length>0{
            r = r  + (UInt64(bytes.removeFirst()) << UInt64(bytes.length * 8 ))
        }

        return Address(r)
    }
}
