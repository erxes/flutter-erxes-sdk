# Keep Material icon classes so action items resolved by name survive R8/ProGuard.
-keep class androidx.compose.material.icons.** { *; }
-keep class androidx.compose.material.icons.filled.** { *; }

# Keep the Erxes native SDK public surface.
-keep class com.erxes.messenger.** { *; }
