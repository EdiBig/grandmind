# Flutter embedding and plugins
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.common.** { *; }

# Firebase and Play Services (defensive; tighten if needed)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Play Core deferred components (avoid missing class build errors)
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# UCrop image cropper library
-keep class com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**
