import '../../../../core/exceptions/exceptions.dart';
import '../../../../network/clients/cancel_token.dart';
import '../../../../shared/utils/result.dart';
import '../../../core/dto/query_params.dart';
import '../../../core/entities/chat/chat_admin.dart';
import '../../../core/entities/chat/chat_details.dart';
import '../../../core/entities/chat/chat_message.dart';
import '../../../network/data_sources/chat_data_source.dart';
import '../../../shared/pagination/model.dart';
import 'chat_repository.dart';

class ChatRepoImpl extends ChatRepository {
  final ChatDataSource _dataSource;

  const ChatRepoImpl({
    required ChatDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  FutureResult<List<ChatDetails>> getChats({
    CancellationToken? cancelToken,
  }) async {
    try {
      final result = await _dataSource.getAllChats(cancelToken);

      return Success(result);
    } on RequestCanceledException {
      return const Canceled();
    } catch (e, stackTrace) {
      if (e is CodedException) {
        return Failure(e, stackTrace);
      }
      return Failure(UnknownException(e.toString()), stackTrace);
    }
  }

  @override
  FutureResult<PaginatedResponse<ChatMessage>> getMessages({
    required String chatId,
    QueryParams? params,
    CancellationToken? cancelToken,
  }) async {
    try {
      final result = await _dataSource.messageList(
        chatId,
        params,
        cancelToken,
      );

      return Success(result);
    } on RequestCanceledException {
      return const Canceled();
    } catch (e, stackTrace) {
      if (e is CodedException) {
        return Failure(e, stackTrace);
      }
      return Failure(UnknownException(e.toString()), stackTrace);
    }
  }

  @override
  FutureResult<ChatDetails> createChat({
    required String adminId,
    CancellationToken? cancelToken,
  }) async {
    try {
      final result = await _dataSource.createChat(
        adminId,
        cancelToken,
      );

      return Success(result);
    } on RequestCanceledException {
      return const Canceled();
    } catch (e, stackTrace) {
      if (e is CodedException) {
        return Failure(e, stackTrace);
      }
      return Failure(UnknownException(e.toString()), stackTrace);
    }
  }

  @override
  FutureResult<List<ChatAdmin>> getAllUsers({
    CancellationToken? cancelToken,
    String? name,
  }) async {
    try {
      final result = await _dataSource.getAllUsers(cancelToken, name);

      return Success(result);
    } on RequestCanceledException {
      return const Canceled();
    } catch (e, stackTrace) {
      if (e is CodedException) {
        return Failure(e, stackTrace);
      }
      return Failure(UnknownException(e.toString()), stackTrace);
    }
  }

  @override
  FutureResult<int> getUnreadMessagesCount(
      {CancellationToken? cancelToken}) async {
    try {
      final result = await _dataSource.getUnreadCount(cancelToken);

      return Success(result);
    } on RequestCanceledException {
      return const Canceled();
    } catch (e, stackTrace) {
      if (e is CodedException) {
        return Failure(e, stackTrace);
      }
      return Failure(UnknownException(e.toString()), stackTrace);
    }
  }

  @override
  FutureResult<ChatDetails> getChatDetails(
      {required String chatId, CancellationToken? cancelToken}) async {
    try {
      final result = await _dataSource.getChatDetails(chatId, cancelToken);
      return Success(result);
    } on RequestCanceledException {
      return const Canceled();
    } catch (e, stackTrace) {
      if (e is CodedException) {
        return Failure(e, stackTrace);
      }
      return Failure(UnknownException(e.toString()), stackTrace);
    }
  }
}
