import 'package:flutter/material.dart';
import 'package:dash_kit_core/dash_kit_core.dart';

class LoadableListView<T extends StoreListItem> extends StatefulWidget {
  const LoadableListView({
    Key key,
    @required this.viewModel,
    this.scrollPhysics = const AlwaysScrollableScrollPhysics(),
    this.onChangeContentOffset,
    this.cacheExtent,
  }) : super(key: key);

  final LoadableListViewModel<T> viewModel;
  final ScrollPhysics scrollPhysics;
  final void Function(double offset) onChangeContentOffset;
  final double cacheExtent;

  @override
  State<StatefulWidget> createState() {
    return LoadableListViewState<T>();
  }
}

class LoadableListViewState<T extends StoreListItem>
    extends State<LoadableListView> {
  final ScrollController scrollController = ScrollController();

  LoadableListViewModel<T> get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    if (viewModel?.loadList != null && viewModel.loadListRequestState.isIdle) {
      viewModel?.loadList();
    }

    scrollController.addListener(() {
      widget.onChangeContentOffset?.call(scrollController.position.pixels);
    });
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
      key: viewModel.key,
      physics: widget.scrollPhysics,
      padding: viewModel.padding,
      itemCount: viewModel.itemsCount,
      controller: scrollController,
      cacheExtent: widget.cacheExtent,
      itemBuilder: buildListItem,
    );
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
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
    @required this.errorWidget,
    @required this.emptyStateWidget,
    this.key,
    this.loadList,
    this.padding,
  })  : assert(items != null),
        assert(itemBuilder != null),
        assert(loadListRequestState != null);

  final Key key;
  final Widget errorWidget;
  final Widget emptyStateWidget;
  final Widget Function(int) itemBuilder;
  final VoidCallback loadList;
  final EdgeInsets padding;
  final StoreList<Item> items;
  final OperationState loadListRequestState;

  int get itemsCount => items.items.length;

  PaginationState getPaginationState() {
    if (loadListRequestState.isFailed) {
      return PaginationState.error;
    }

    if (loadListRequestState.isInProgress ||
        loadListRequestState.isRefreshing) {
      return PaginationState.loading;
    }

    if (loadListRequestState.isSucceed && items.items.isEmpty) {
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
