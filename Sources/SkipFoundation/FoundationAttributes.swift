// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

public enum AttributeScopes {
  public static var foundation: FoundationAttributes.Type { FoundationAttributes.self }

  public struct FoundationAttributes : AttributeScope {
    public enum LinkAttribute : AttributedStringKey {
      public typealias Value = URL
      public static let name = "Link"
    }

    /// Markdown bold (**text**).
    public enum MarkdownBoldAttribute : AttributedStringKey {
      public typealias Value = Bool
      public static let name = "MarkdownBold"
    }

    /// Markdown italic (*text*).
    public enum MarkdownItalicAttribute : AttributedStringKey {
      public typealias Value = Bool
      public static let name = "MarkdownItalic"
    }

    /// Markdown strikethrough (~~text~~).
    public enum MarkdownStrikethroughAttribute : AttributedStringKey {
      public typealias Value = Bool
      public static let name = "MarkdownStrikethrough"
    }

    /// Markdown inline code (`text`).
    public enum MarkdownCodeAttribute : AttributedStringKey {
      public typealias Value = Bool
      public static let name = "MarkdownCode"
    }
  }
}

extension AttributeContainer {
  public var link: URL? {
    get { value(key: AttributeScopes.FoundationAttributes.LinkAttribute.name) as? URL }
    set { setValue(newValue, key: AttributeScopes.FoundationAttributes.LinkAttribute.name) }
  }

  public var markdownBold: Bool {
    get { value(key: AttributeScopes.FoundationAttributes.MarkdownBoldAttribute.name) as? Bool == true }
    set { setValue(newValue, key: AttributeScopes.FoundationAttributes.MarkdownBoldAttribute.name) }
  }

  public var markdownItalic: Bool {
    get { value(key: AttributeScopes.FoundationAttributes.MarkdownItalicAttribute.name) as? Bool == true }
    set { setValue(newValue, key: AttributeScopes.FoundationAttributes.MarkdownItalicAttribute.name) }
  }

  public var markdownStrikethrough: Bool {
    get { value(key: AttributeScopes.FoundationAttributes.MarkdownStrikethroughAttribute.name) as? Bool == true }
    set { setValue(newValue, key: AttributeScopes.FoundationAttributes.MarkdownStrikethroughAttribute.name) }
  }

  public var markdownCode: Bool {
    get { value(key: AttributeScopes.FoundationAttributes.MarkdownCodeAttribute.name) as? Bool == true }
    set { setValue(newValue, key: AttributeScopes.FoundationAttributes.MarkdownCodeAttribute.name) }
  }
}

extension AttributedString {
  public var link: URL? {
    get { attributeValue(key: AttributeScopes.FoundationAttributes.LinkAttribute.name) as? URL }
    mutating set { setAttributeValue(newValue, key: AttributeScopes.FoundationAttributes.LinkAttribute.name) }
  }
}

#endif
