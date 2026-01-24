/// Pagination module for Firestore cursor-based pagination
///
/// This module provides:
/// - [PaginatedResult] - Result model for paginated queries
/// - [PaginationState] - State wrapper with loading/error status
/// - [PaginatedRepository] - Mixin for adding pagination to repositories
/// - [PaginatedListView] - Widget for infinite scroll lists
/// - [PaginationNotifier] - Riverpod StateNotifier for pagination
///
/// ## Quick Start
///
/// ### 1. Add pagination to a repository
///
/// ```dart
/// class MealRepository with PaginatedRepository {
///   Future<PaginatedResult<Meal>> getMealsPaginated({
///     required String userId,
///     int pageSize = 20,
///     DocumentSnapshot? startAfter,
///   }) async {
///     final baseQuery = _firestore
///         .collection('meals')
///         .where('userId', isEqualTo: userId)
///         .orderBy('mealDate', descending: true);
///
///     return executePaginatedQuery(
///       baseQuery: baseQuery,
///       fromJson: Meal.fromJson,
///       pageSize: pageSize,
///       startAfterDocument: startAfter,
///     );
///   }
/// }
/// ```
///
/// ### 2. Create a pagination notifier
///
/// ```dart
/// class MealsPaginationNotifier extends PaginationNotifier<Meal> {
///   final MealRepository _repository;
///   final String _userId;
///
///   MealsPaginationNotifier(this._repository, this._userId);
///
///   @override
///   Future<PaginatedResult<Meal>> fetchPage(int page, dynamic cursor) {
///     return _repository.getMealsPaginated(
///       userId: _userId,
///       startAfter: cursor as DocumentSnapshot?,
///     );
///   }
/// }
///
/// final mealsPaginationProvider = StateNotifierProvider.family<
///     MealsPaginationNotifier, PaginationState<Meal>, String>((ref, userId) {
///   final repository = ref.watch(mealRepositoryProvider);
///   return MealsPaginationNotifier(repository, userId);
/// });
/// ```
///
/// ### 3. Use in a screen
///
/// ```dart
/// class MealsScreen extends ConsumerStatefulWidget {
///   @override
///   ConsumerState<MealsScreen> createState() => _MealsScreenState();
/// }
///
/// class _MealsScreenState extends ConsumerState<MealsScreen> {
///   @override
///   void initState() {
///     super.initState();
///     // Load first page
///     Future.microtask(() {
///       ref.read(mealsPaginationProvider(userId).notifier).loadFirstPage();
///     });
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     final paginationState = ref.watch(mealsPaginationProvider(userId));
///
///     return PaginatedListView<Meal>(
///       state: paginationState,
///       onLoadMore: () {
///         ref.read(mealsPaginationProvider(userId).notifier).loadNextPage();
///       },
///       itemBuilder: (context, meal, index) => MealCard(meal: meal),
///       emptyBuilder: (context) => const EmptyMealsWidget(),
///     );
///   }
/// }
/// ```

library pagination;

// Models
export 'models/paginated_result.dart';

// Mixins
export 'mixins/paginated_repository.dart';

// Providers
export 'providers/pagination_notifier.dart';

// Widgets
export 'widgets/paginated_list_view.dart';
