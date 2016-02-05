//
//  RouterMiddleware.swift
//  RouterMiddleware
//
//  Created by Samuel Kallner on 11/22/15.
//  Copyright © 2015 IBM. All rights reserved.
//

public protocol RouterMiddleware {
    func handle(request: RouterRequest, response: RouterResponse, next: () -> Void)
}