# For Fresco (image library used by Facebook packages)
-keep class com.facebook.imagepipeline.nativecode.** { *; }
-keep class com.facebook.imagepipeline.** { *; }

# For Jackson (used for JSON serialization/deserialization)
-keep class com.fasterxml.jackson.databind.** { *; }
-keep class java.beans.** { *; }
-keep class org.w3c.dom.bootstrap.** { *; }

# Prevent R8 from stripping required classes
-dontwarn com.facebook.imagepipeline.**
-dontwarn com.fasterxml.jackson.databind.**
-dontwarn java.beans.**
-dontwarn org.w3c.dom.bootstrap.**
