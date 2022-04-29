import Foundation

// YOU DON'T HAVE TO USE THIS CONSTANT, BUT IT MIGHT BE USEFUL
let operators: [String: (Double, Double) -> Double] = ["+": (+), "-": (-), "*": (*), "/": (/)]

func main() {
    while true {
        print("Calc>", terminator: " ")

        let expr = readLine()!

        if expr == ":q" { break }

        let evalExpr = evaluate(tokenize(expr))
        if evalExpr == nil {
            print("ERROR: cannot read expression \"\(expr)\"")
        } else {
            print(evalExpr!)
        }
    }
}

func tokenize(_ s: String) -> [String] {
    var string = ""
    for char in s {
        if char == ")" {
            string.append(" ")
        }
        string.append(char)
        if char == "(" {
            string.append(" ")
        }
    }
    return string.split(separator: " ").map({ String($0) })
}

func findOp(_ tokens: [String]) -> (op: String, left: [String], right: [String])? {
    let opPrecedence: [String: Int] = ["+": 0, "-": 0, "*": 1, "/": 1]
    var numOpenParen = 0
    var opIndex = -1

    for (index, token) in tokens.enumerated() {
        if token == "(" {
            numOpenParen += 1
        }
        if token == ")" {
            numOpenParen -= 1
        }
        if opPrecedence[token] != nil && numOpenParen == 0 {
            if opIndex < 0 || opPrecedence[tokens[opIndex]]! >= opPrecedence[token]! {
                opIndex = index
            }
        }
    }

    if opIndex == -1 {
        return nil
    }
    return (tokens[opIndex], Array(tokens.prefix(upTo: opIndex)), Array(tokens.suffix(from: opIndex < tokens.endIndex ? opIndex + 1: tokens.endIndex)))
}

func isBalanced(_ l: [String]) -> Bool {
    var count = 0
    for str in l {
        if str == "(" {
            count += 1
        }
        if str == ")" {
            count -= 1
        }
        if count < 0 {
            return false
        }
    }
    return count == 0
}

// If parentheses are provided with no operator within them or beside them (with a space) this function will return nil
func evaluate(_ tokens: [String]) -> Double? {
    // TODO: Part 3
    var t = tokens
    // operands with no values to compute or parentheses that are unbalanced
    if t.isEmpty || !isBalanced(t) {
        return nil
    }
    // completely unwrapped array with a single value
    if t.count == 1 {
        return Double(t[0])
    }

    let optionalResult = findOp(t)

    if optionalResult == nil {
        // Hit a case where the expression to be evaluated is wrapped in parentheses
        // For example : ["(", "1", "+", "2", ")"]
        // We know that this is balanced from the isBalanced call, so don't need to check on lastIndex
        let firstP = t.firstIndex(of: "(")
        let lastP = t.lastIndex(of: ")")
        if firstP != nil && lastP != nil && firstP! == 0 && lastP! == t.count - 1 {
            t.remove(at: firstP!)
            t.remove(at: lastP! - 1)
            return evaluate(t)
        }
        return nil
    }

    let result = optionalResult!

    let left: [String] = result.left
    let right: [String] = result.right

    let op: (Double, Double) -> Double = operators[result.op]!
    let leftResult: Double? = evaluate(left)
    let rightResult: Double? = evaluate(right)

    if leftResult == nil || rightResult == nil {
        return nil
    }
    return op(leftResult!, rightResult!)
}

main()
