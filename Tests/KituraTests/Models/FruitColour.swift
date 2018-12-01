/*
 * Copyright IBM Corporation 2018
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Why doesn't this work?
//public enum FruitColour: String, Codable {
//    case yellow, green, red, purple, orange
//}

public struct FruitColour: Codable {
    let colour: String

    static let yellow = FruitColour(colour: "yellow")
    static let green = FruitColour(colour: "green")
    static let red = FruitColour(colour: "red")
    static let purple = FruitColour(colour: "purple")
    static let orange = FruitColour(colour: "orange")
}
