Pod::Spec.new do |s|

  s.name         = "Torch"
  s.version      = "2.0.2"
  s.summary      = "A lightweight Swift Pull to refresh control."

  s.description  = <<-DESC
  					Torch is a pull to refresh written in pure swift.
                   DESC

  s.homepage     = "https://github.com/kukushi/Torch"
  s.license      = "MIT"
  s.author       = { "Xing He" => "" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/kukushi/Torch.git", :tag => s.version }
  s.source_files  = "Classes", "Classes/**/*.{h,m}", "Torch/*.{h,m,swift}"
  s.exclude_files = "Classes/Exclude"
  s.swift_version = "5.0"
  s.requires_arc = true

end
