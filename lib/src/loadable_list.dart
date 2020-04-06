import 'package:flutter/material.dart';
import 'package:flutter_platform_core/flutter_platform_core.dart';

class LoadableList<T extends StoreListItem> extends StatefulWidget {
  const LoadableList({Key key, @required this.viewModel}) : super(key: key);

  final LoadableListViewModel<T> viewModel;

  @override
  State<StatefulWidget> createState() {
    return LoadableListState<T>();
  }
}

class LoadableListState<T extends StoreListItem> extends State<LoadableList>
    with ReduxState {

  final ScrollController scrollController = ScrollController();
  LoadableListViewModel<T> get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    if (viewModel?.loadList != null && viewModel.loadListRequestState.isIdle) {
      viewModel?.loadList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = viewModel.getPaginationState();

    switch (state) {
      case PaginationState.loading:
        return buildProgressState();
      case PaginationState.empty:
        return buildEmptyState();
      case PaginationState.error:
        return buildErrorState();
      default:
        break;
    }

    return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: viewModel.padding,
        itemCount: viewModel.itemsCount,
        controller: scrollController,
        cacheExtent: 1000000,
        itemBuilder: buildListItem);
  }

  Widget buildProgressState() {
    return Container(
      padding: viewModel.padding,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget buildErrorState() {
    return viewModel.errorWidget ?? Container();
  }

  Widget buildEmptyState() {
    return viewModel.emptyStateWidget ?? Container();
  }

  Widget getLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildListItem(BuildContext context, int index) {
    return viewModel.itemBuilder(index);
  }
}

class LoadableListViewModel<Item extends StoreListItem> {
  const LoadableListViewModel({
    @required this.itemBuilder,
    @required this.items,
    @required this.loadListRequestState,
    this.errorWidget,
    this.emptyStateWidget,
    this.loadList,
    this.padding,
  })  : assert(items != null),
        assert(itemBuilder != null),
        assert(loadListRequestState != null);

  final Widget errorWidget;
  final Widget emptyStateWidget;
  final Widget Function(int) itemBuilder;
  final VoidCallback loadList;
  final EdgeInsets padding;
  final StoreList<Item> items;
  final RefreshableRequestState loadListRequestState;

  int get itemsCount => items.items.length;

  PaginationState getPaginationState() {
    if (loadListRequestState.isFailed) {
      return PaginationState.error;
    } else if (loadListRequestState.isInProgress) {
      return PaginationState.loading;
    } else if (loadListRequestState.isSucceed && items.items.isEmpty) {
      return PaginationState.empty;
    }

    return PaginationState.idle;
  }
}

enum PaginationState {
  idle,
  empty,
  loading,
  loadingPage,
  error,
  errorLoadingPage,
}
