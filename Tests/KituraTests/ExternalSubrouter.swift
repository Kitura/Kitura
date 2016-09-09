/// For use with TestSubrouter.swift


import Kitura
import KituraNet

class ExternSubrouter {
	static func getRouter() -> Router {
		let externSubrouter = Router()

		externSubrouter.get("/") { request, response, next in
		    response.status(HTTPStatusCode.OK).send("hello from the sub")
		    next()
		}

		externSubrouter.get("/sub1") { request, response, next in
		    response.status(HTTPStatusCode.OK).send("sub1")
		    next()
		}

		return externSubrouter
	}
}
