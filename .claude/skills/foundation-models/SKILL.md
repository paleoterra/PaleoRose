---
description: Implement on-device AI features using Apple's Foundation Models framework with guided generation, tool calling, and structured outputs
---

# Foundation Models Framework

Implement on-device AI features using Apple's Foundation Models framework with guided generation, tool calling, and structured outputs.

## Overview

The Foundation Models framework (introduced at WWDC 2025) provides direct access to Apple's ~3B parameter on-device language model. This framework enables developers to create reliable, production-quality generative AI features that run entirely on-device for maximum privacy and offline capability.

**Platform Requirements:**
- iOS 26+, iPadOS 26+, macOS 26+
- Apple Silicon recommended for optimal performance
- Runs on-device with full offline support

## Capabilities

1. **Guided Generation**
   - Use `@Generable` macro to generate structured outputs from Swift types
   - Work directly with rich Swift data structures (structs, enums)
   - Define expected output schemas declaratively
   - Get type-safe results without manual parsing
   - Support for complex nested structures

2. **Tool Calling**
   - Define tools that the model can autonomously invoke
   - Enable the model to access external information
   - Perform actions for personalized experiences
   - Create multi-step agentic workflows
   - Provide function calling capabilities

3. **Language Understanding**
   - Text generation and completion
   - Summarization and analysis
   - Question answering
   - Content extraction and transformation
   - Natural language processing

4. **Privacy & Performance**
   - All processing happens on-device
   - Data never leaves the user's device
   - Works offline without network connectivity
   - Optimized for Apple Silicon
   - Low latency responses

## Core Framework Components

### LanguageModel
The main interface for interacting with the on-device model:
```swift
import FoundationModels

let model = LanguageModel.default
```

### @Generable Macro
Annotate Swift types to enable guided generation:
```swift
@Generable
struct RecipeIngredient {
    var name: String
    var amount: String
    var unit: String
}

@Generable
struct Recipe {
    var title: String
    var ingredients: [RecipeIngredient]
    var steps: [String]
    var cookingTime: Int
}
```

### GenerationConfiguration
Configure generation parameters:
```swift
var config = GenerationConfiguration()
config.temperature = 0.7
config.topP = 0.9
config.maxTokens = 512
```

### Tool Protocol
Define tools that the model can call:
```swift
struct WeatherTool: Tool {
    var name = "get_weather"
    var description = "Get current weather for a location"

    func invoke(with parameters: [String: Any]) async throws -> ToolResult {
        // Implement tool logic
    }
}
```

## Common Patterns

### 1. Structured Data Extraction

Extract structured information from unstructured text:

```swift
@Generable
struct ContactInfo {
    var name: String
    var email: String?
    var phone: String?
    var company: String?
}

let prompt = """
Extract contact information from this email:
Hi, I'm Sarah Johnson from Acme Corp.
You can reach me at sarah.j@acme.com or 555-0123.
"""

let result = try await model.generate(
    prompt: prompt,
    as: ContactInfo.self
)
```

### 2. Classification with Enums

Use enums for classification tasks:

```swift
@Generable
enum Sentiment {
    case positive
    case negative
    case neutral
}

@Generable
struct ReviewAnalysis {
    var sentiment: Sentiment
    var confidence: Double
    var keyPhrases: [String]
}

let review = "This product exceeded my expectations!"
let analysis = try await model.generate(
    prompt: "Analyze this review: \(review)",
    as: ReviewAnalysis.self
)
```

### 3. Tool Calling Pattern

Enable the model to access external data:

```swift
struct DatabaseTool: Tool {
    var name = "query_database"
    var description = "Query customer database"

    func invoke(with parameters: [String: Any]) async throws -> ToolResult {
        guard let query = parameters["query"] as? String else {
            throw ToolError.invalidParameters
        }
        // Execute database query
        let results = await database.execute(query)
        return ToolResult(content: results)
    }
}

let tools = [DatabaseTool()]
let response = try await model.generate(
    prompt: "Find all orders from last month",
    tools: tools
)
```

### 4. Multi-Step Generation

Chain multiple generation steps:

```swift
// Step 1: Understand intent
@Generable
struct Intent {
    var action: String
    var entities: [String: String]
}

let intent = try await model.generate(
    prompt: userInput,
    as: Intent.self
)

// Step 2: Generate response based on intent
let response = try await model.generate(
    prompt: "Create a response for \(intent.action) with \(intent.entities)"
)
```

### 5. Streaming Responses

Stream tokens as they're generated:

```swift
for try await token in model.generateStream(prompt: prompt) {
    // Update UI incrementally
    await MainActor.run {
        textView.append(token)
    }
}
```

## Best Practices

### Model Initialization
```swift
// Initialize model once and reuse
class AIService {
    private let model = LanguageModel.default

    func process(_ input: String) async throws -> Result {
        try await model.generate(prompt: input, as: Result.self)
    }
}
```

### Prompt Engineering
- Be specific and clear in your prompts
- Provide context and examples when needed
- Use system prompts to set behavior
- Structure prompts consistently
- Test with various inputs

### Error Handling
```swift
do {
    let result = try await model.generate(prompt: prompt, as: MyType.self)
    return result
} catch let error as GenerationError {
    switch error {
    case .invalidSchema:
        // Handle schema validation errors
    case .modelUnavailable:
        // Handle model not available
    case .timeout:
        // Handle timeout
    default:
        // Handle other errors
    }
}
```

### Memory Management
- Dispose of large generation sessions when done
- Use weak references in callbacks
- Monitor memory usage in resource-constrained scenarios
- Consider pagination for large datasets

### Testing
```swift
@Test
func testRecipeGeneration() async throws {
    let model = LanguageModel.default
    let prompt = "Create a simple pasta recipe"

    let recipe = try await model.generate(
        prompt: prompt,
        as: Recipe.self
    )

    #expect(!recipe.ingredients.isEmpty)
    #expect(!recipe.steps.isEmpty)
    #expect(recipe.cookingTime > 0)
}
```

## Schema Design Guidelines

### Make Types @Generable
Always annotate types used with the model:
```swift
@Generable
struct Article {
    var title: String
    var summary: String
    var tags: [String]
}
```

### Use Optional for Uncertain Fields
```swift
@Generable
struct Person {
    var name: String
    var age: Int?           // Might not be mentioned
    var occupation: String? // Might be unknown
}
```

### Provide Clear Property Names
```swift
@Generable
struct Event {
    var eventName: String        // Clear
    var startDateTime: Date      // Explicit
    var durationInMinutes: Int   // Unambiguous
}
```

### Use Enums for Constrained Values
```swift
@Generable
enum Priority {
    case low, medium, high, urgent
}

@Generable
struct Task {
    var title: String
    var priority: Priority  // Limited to enum cases
}
```

### Nested Structures
```swift
@Generable
struct Address {
    var street: String
    var city: String
    var zipCode: String
}

@Generable
struct Customer {
    var name: String
    var addresses: [Address]  // Nested array of structs
}
```

## Advanced Features

### Custom Tools Implementation
```swift
protocol AdvancedTool: Tool {
    var parameters: [ToolParameter] { get }
    func validate(_ params: [String: Any]) -> Bool
}

struct SearchTool: AdvancedTool {
    var name = "search"
    var description = "Search the knowledge base"

    var parameters: [ToolParameter] {
        [
            ToolParameter(name: "query", type: .string, required: true),
            ToolParameter(name: "limit", type: .integer, required: false)
        ]
    }

    func validate(_ params: [String: Any]) -> Bool {
        params["query"] is String
    }

    func invoke(with parameters: [String: Any]) async throws -> ToolResult {
        // Implementation
    }
}
```

### Configuration Profiles
```swift
extension GenerationConfiguration {
    static var creative: GenerationConfiguration {
        var config = GenerationConfiguration()
        config.temperature = 0.9
        config.topP = 0.95
        return config
    }

    static var precise: GenerationConfiguration {
        var config = GenerationConfiguration()
        config.temperature = 0.3
        config.topP = 0.5
        return config
    }
}

let result = try await model.generate(
    prompt: prompt,
    configuration: .creative,
    as: Story.self
)
```

### Context Management
```swift
class ConversationContext {
    private var messages: [Message] = []
    private let model = LanguageModel.default

    func addUserMessage(_ text: String) {
        messages.append(Message(role: .user, content: text))
    }

    func generateResponse() async throws -> String {
        let context = messages.map { "\($0.role): \($0.content)" }
            .joined(separator: "\n")

        let response = try await model.generate(prompt: context)
        messages.append(Message(role: .assistant, content: response))
        return response
    }
}
```

## Integration Patterns

### SwiftUI Integration
```swift
@Observable
class AIViewModel {
    private let model = LanguageModel.default
    var response: String = ""
    var isGenerating = false

    func generateContent(from prompt: String) async {
        isGenerating = true
        defer { isGenerating = false }

        do {
            response = ""
            for try await token in model.generateStream(prompt: prompt) {
                response += token
            }
        } catch {
            response = "Error: \(error.localizedDescription)"
        }
    }
}

struct ContentView: View {
    @State private var viewModel = AIViewModel()
    @State private var prompt = ""

    var body: some View {
        VStack {
            TextField("Enter prompt", text: $prompt)
            Button("Generate") {
                Task {
                    await viewModel.generateContent(from: prompt)
                }
            }
            .disabled(viewModel.isGenerating)

            Text(viewModel.response)
                .textSelection(.enabled)
        }
    }
}
```

### AppKit Integration
```swift
class AIWindowController: NSWindowController {
    private let model = LanguageModel.default
    @IBOutlet weak var inputField: NSTextField!
    @IBOutlet weak var outputView: NSTextView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!

    @IBAction func generate(_ sender: Any) {
        let prompt = inputField.stringValue
        progressIndicator.startAnimation(nil)

        Task {
            do {
                let result = try await model.generate(prompt: prompt)
                await MainActor.run {
                    outputView.string = result
                    progressIndicator.stopAnimation(nil)
                }
            } catch {
                await MainActor.run {
                    outputView.string = "Error: \(error)"
                    progressIndicator.stopAnimation(nil)
                }
            }
        }
    }
}
```

### Background Processing
```swift
class BackgroundAIProcessor {
    private let model = LanguageModel.default

    func processItems(_ items: [Item]) async throws -> [ProcessedItem] {
        try await withThrowingTaskGroup(of: ProcessedItem.self) { group in
            for item in items {
                group.addTask {
                    try await self.processItem(item)
                }
            }

            var results: [ProcessedItem] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }

    private func processItem(_ item: Item) async throws -> ProcessedItem {
        let analysis = try await model.generate(
            prompt: "Analyze: \(item.content)",
            as: ItemAnalysis.self
        )
        return ProcessedItem(item: item, analysis: analysis)
    }
}
```

## Workflow

When helping users implement Foundation Models features, follow this workflow:

1. **Understand Requirements**
   - What task needs AI? (extraction, generation, classification, etc.)
   - What data structures are involved?
   - Is tool calling needed for external data?
   - What's the desired output format?

2. **Design Schema**
   - Create `@Generable` structs/enums for outputs
   - Use clear, descriptive property names
   - Make uncertain fields optional
   - Use enums for constrained values

3. **Implement Generation**
   - Write clear, specific prompts
   - Configure appropriate temperature/parameters
   - Add error handling
   - Consider streaming for long responses

4. **Add Tools (if needed)**
   - Implement Tool protocol for external data access
   - Define clear tool descriptions
   - Validate tool parameters
   - Handle tool errors gracefully

5. **Test & Refine**
   - Test with various inputs
   - Validate output quality
   - Adjust prompts and configuration
   - Handle edge cases
   - Monitor performance

6. **Integrate with UI**
   - Show loading states during generation
   - Stream responses when possible
   - Handle errors with user-friendly messages
   - Provide cancellation if needed

## Common Use Cases

### Content Extraction
Extract structured data from emails, documents, receipts, forms, etc.

### Classification & Tagging
Categorize content, detect sentiment, assign tags, prioritize items.

### Summarization
Create summaries of long documents, conversations, or data.

### Form Filling
Auto-populate forms from natural language or existing data.

### Smart Suggestions
Generate contextual suggestions based on user input.

### Data Enrichment
Enhance existing data with generated descriptions, categories, etc.

### Question Answering
Answer questions based on provided context or documents.

### Code Generation
Generate code snippets, documentation, or test cases.

## Troubleshooting

### Model Not Available
- Verify platform requirements (iOS 26+, macOS 26+)
- Check device compatibility
- Ensure sufficient storage space

### Poor Output Quality
- Refine prompt clarity and specificity
- Adjust temperature (lower for precision, higher for creativity)
- Provide more context or examples
- Review schema design for ambiguity

### Schema Validation Errors
- Ensure all types are marked @Generable
- Check for unsupported property types
- Verify enum cases are valid
- Test with simpler schemas first

### Performance Issues
- Reduce maxTokens if responses are slow
- Consider caching for repeated queries
- Use streaming for better perceived performance
- Profile and optimize prompt length

### Tool Calling Issues
- Verify tool descriptions are clear
- Validate parameters are properly typed
- Check tool implementation for errors
- Test tools independently first

## Resources

- **Official Documentation**: https://developer.apple.com/documentation/FoundationModels
- **WWDC 2025 Sessions**:
  - "Meet the Foundation Models framework" (Session 286)
  - "Deep dive into the Foundation Models framework" (Session 301)
  - "Code-along: Bring on-device AI to your app" (Session 259)
- **Sample Code**: Available in Apple Developer downloads
- **Community**: Apple Developer Forums - Machine Learning & AI

## Privacy & Ethics

### Privacy Considerations
- All processing is on-device
- No data sent to servers
- User data stays private
- Works offline
- No tracking or telemetry

### Responsible AI Usage
- Clearly indicate AI-generated content
- Validate critical outputs
- Handle sensitive data appropriately
- Provide user control over AI features
- Consider accessibility implications
- Test for bias in outputs

## Example Project Structure

```
MyApp/
├── Models/
│   ├── GenerableTypes.swift      // @Generable definitions
│   └── AIModels.swift             // Domain models
├── Services/
│   ├── AIService.swift            // Main AI service
│   ├── Tools/
│   │   ├── SearchTool.swift
│   │   └── DatabaseTool.swift
│   └── Configuration/
│       └── GenerationConfigs.swift
├── ViewModels/
│   └── ContentViewModel.swift     // SwiftUI integration
└── Views/
    └── ContentView.swift          // UI layer
```

## Migration Notes

### From Custom LLM Integrations
If migrating from third-party LLM services:
- Replace API calls with FoundationModels framework
- Convert JSON schemas to @Generable types
- Remove network error handling (on-device = no network)
- Update privacy policies (no data leaving device)
- Remove API key management

### From Previous ML Approaches
If migrating from CoreML or other ML frameworks:
- Much simpler API - no model management
- No need to bundle or download models
- Automatic updates through OS
- Better language understanding out-of-box

---

**Note**: This skill assumes you're working with the Foundation Models framework introduced at WWDC 2025. Ensure your project targets iOS 26+, iPadOS 26+, or macOS 26+ to use these APIs.
