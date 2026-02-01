/// Unity Widgets
library unity_widgets;

/// Export all Unity widgets for easy importing.
/// These are reusable UI components for the Unity social fitness feature.

// Challenge widgets
export 'challenge_card.dart';
export 'active_challenge_card.dart';

// Circle widgets
// Note: circle_avatar_widget.dart exports UnityCircleAvatar (renamed to avoid Flutter conflict)
export 'circle_avatar_widget.dart';
export 'circle_avatar.dart';
export 'circle_card.dart';

// Progress widgets
// Note: Only export from progress_bar.dart to avoid duplicate UnityProgressBar
export 'progress_bar.dart';
export 'progress_portrait.dart';

// Cheer widgets
export 'cheer_button.dart';
export 'cheer_selector.dart';

// Feed widgets
export 'feed_post_card.dart';

// Milestone widgets
export 'milestone_badge.dart';

// Tier selection widgets
export 'tier_selection_card.dart';
export 'tier_selector.dart';

// Privacy and settings widgets
export 'whisper_mode_toggle.dart';
export 'rest_day_card.dart';

// Consent widgets
export 'consent_checkbox.dart';
