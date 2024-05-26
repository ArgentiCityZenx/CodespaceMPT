
import SwiftUI
import PlaygroundSupport
 // Import MarkdownUI framework for rendering Markdown content
 
struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
         
                Text("Dashboard")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                
                Spacer()
                
                NavigationLink(destination: TerminalView()) {
                    HStack {
                        Image(systemName: "command.square")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                        
                        Text("Terminal")
                            .foregroundColor(.white)
                            .padding(.trailing, 20)
                    }
                    .frame(height: 50)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                }
              
                
                NavigationLink(destination: MarkdownEditorView()) {
                    HStack {
                        Image(systemName: "pencil")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                        
                        Text("Markdown Editor")
                            .foregroundColor(.white)
                            .padding(.trailing, 20)
                    }
                    .frame(height: 50)
                     .background(Color.red)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                }
               
                
    
                NavigationLink(destination: CodeBoxView()) {
                    HStack {
                        Image(systemName: "laptopcomputer")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                        
                        Text("Coding")
                            .foregroundColor(.white)
                            .padding(.trailing, 20)
                    }
                    .frame(height: 50)
                     .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                }

                .padding(.bottom, 20)
                
                Spacer()
           }
        }
    }
}


            
            struct TerminalView: View {
                @State private var command: String = ""
                @State private var terminalOutput: [String] = ["Type \"help\" for a list of commands."]
                
                var body: some View {
                    VStack(alignment: .leading) {
                        Text("Terminal")
                            .font(.largeTitle)
                            .bold()
                            .padding(.leading, 20)
                            .padding(.top, 20)
                        
                        ScrollView {
                            ForEach(terminalOutput, id: \.self) { output in
                                Text(output)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(height: 300)
                        .background(Color.black)
                        .foregroundColor(.green)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                        HStack {
                            TextField("Type your command here...", text: $command, onCommit: executeCommand)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                               
                        }
                        .padding()
                    }
                }

                func executeCommand() {
                    let trimmedCommand = command.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmedCommand.isEmpty else { return }
                    
                    terminalOutput.append("> \(trimmedCommand)")
                    let args = trimmedCommand.split(separator: " ")
                    let cmd = args[0]
                    
                    switch cmd {
                    case "help":
                        terminalOutput.append(contentsOf: [
                            "Commands:",
                            "help - Show this help message",
                            "echo [message] - Display a message",
                            "date - Show current date",
                            "time - Show current time",
                            "getipv4 - Get IPv4 address",
                            "getipv6 - Get IPv6 address",
                            "github [username] [repo] - Get files from a GitHub repository",
                            "fork [username] [repo] - Fork a GitHub repository"
                        ])
                    case "echo":
                        terminalOutput.append(args.dropFirst().joined(separator: " "))
                    case "date":
                        terminalOutput.append("\(Date().formatted(.dateTime.month().day().year()))")
                    case "time":
                        terminalOutput.append("\(Date().formatted(.dateTime.hour().minute().second()))")
                    case "getipv4":
                        fetchIPAddress(url: "https://api.ipify.org?format=json", version: "IPv4")
                    case "getipv6":
                        fetchIPAddress(url: "https://api64.ipify.org?format=json", version: "IPv6")
                    case "github":
                        if args.count == 3 {
                            let username = args[1]
                            let repo = args[2]
                            terminalOutput.append("Fetching files from GitHub repository \(username)/\(repo)...")
                            fetchGitHubFiles(username: String(username), repo: String(repo))
                        } else {
                            terminalOutput.append("Usage: github [username] [repo]")
                        }
                    case "fork":
                        if args.count == 3 {
                            let username = args[1]
                            let repo = args[2]
                            let forkUrl = "https://github.com/\(username)/\(repo)/fork"
                            terminalOutput.append("Fork this repository by visiting: \(forkUrl)")
                            // In a real app, you could use SafariServices to open the URL.
                        } else {
                            terminalOutput.append("Usage: fork [username] [repo]")
                        }
                    default:
                        terminalOutput.append("Command not recognized: \(cmd)")
                    }
                    
                    command = ""
                }
                
                func fetchIPAddress(url: String, version: String) {
                    guard let url = URL(string: url) else {
                        terminalOutput.append("Invalid URL for \(version) address")
                        return
                    }
                    
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        if let error = error
                        {
                            DispatchQueue.main.async {
                                terminalOutput.append("Error fetching \(version) address: \(error.localizedDescription)")
                            }
                            return
                        }
                        guard let data = data else {
                            DispatchQueue.main.async {
                                terminalOutput.append("Error fetching \(version) address: No data")
                            }
                            return
                        }
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                               let ip = json["ip"] as? String {
                                DispatchQueue.main.async {
                                    terminalOutput.append("\(version) Address: \(ip)")
                                }
                            } else {
                                DispatchQueue.main.async {
                                    terminalOutput.append("Error fetching \(version) address: Invalid response")
                                }
                            }
                        } catch {
                            DispatchQueue.main.async {
                                terminalOutput.append("Error fetching \(version) address: \(error.localizedDescription)")
                            }
                        }
                    }.resume()
                }
                
                func fetchGitHubFiles(username: String, repo: String) {
                    let urlString = "https://api.github.com/repos/\(username)/\(repo)/contents"
                    guard let url = URL(string: urlString) else {
                        terminalOutput.append("Invalid URL for GitHub repository")
                        return
                    }
                    
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        if let error = error {
                            DispatchQueue.main.async {
                                terminalOutput.append("Error fetching files: \(error.localizedDescription)")
                            }
                            return
                        }
                        guard let data = data else {
                            DispatchQueue.main.async {
                                terminalOutput.append("Error fetching files: No data")
                            }
                            return
                        }
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                                DispatchQueue.main.async {
                                    terminalOutput.append("Files:")
                                    for file in json {
                                        if let name = file["name"] as? String {
                                            terminalOutput.append(name)
                                        }
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    terminalOutput.append("Error fetching files: Invalid response")
                                }
                            }
                        } catch {
                            DispatchQueue.main.async {
                                terminalOutput.append("Error fetching files: \(error.localizedDescription)")
                            }
                        }
                    }.resume()
                }
            }
            
            struct MarkdownEditorView: View {
                @State private var markdownText: String = "# Welcome to the Markdown Editor\n\nType your markdown here..."
                
                var body: some View {
                    VStack(alignment: .leading) {
                        Text("Markdown Editor")
                            .font(.largeTitle)
                            .bold()
                            .padding(.leading, 20)
                            .padding(.top, 20)
                        
                        TextEditor(text: $markdownText)
                            .padding()
                            .border(Color.gray, width: 1)
                            .padding(.horizontal)
                    }
                }
            }

import SwiftUI

struct CodeBoxView: View {
    @State private var codeLines: [Int] = [1] // Initial line number
    @State private var code: String = ""
    
    var body: some View {
        VStack {
            Text("Note that when using the code editor, you may have to scroll on the lines to get the amount of lines on your code. Then, once you are done, copy and paste your code to a .txt file! If you have fixes for these things, make a pull request on GitHub!")
                .padding()
            
            HStack(spacing: 0) {
                // Scrollable line numbers
                ScrollView(.vertical) {
                    VStack(alignment: .trailing, spacing: 7) {
                        ForEach(codeLines, id: \.self) { lineNumber in
                            Text("\(lineNumber)")
                                .foregroundColor(.secondary)
                                .padding(.leading, 5)
                                .frame(width: 60, alignment: .trailing)
                        }
                    }
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(UIColor.separator), lineWidth: 1)
                    )
                }
                .frame(width: 50)
                
                Spacer() // Fill remaining space
                
                // Scrollable TextEditor for code input
                ScrollView(.vertical) {
                    TextEditor(text: $code)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(UIColor.separator), lineWidth: 1)
                        )
                        .onChange(of: code) { _ in
                            updateLineNumbers()
                        }
                }
            }
        }
        .padding()
        .onAppear {
            updateLineNumbers()
        }
    }
    
    private func updateLineNumbers() {
        let newLineCount = code.components(separatedBy: .newlines).count
        codeLines = Array(1...newLineCount)
    }
}
