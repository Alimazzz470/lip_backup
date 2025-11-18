import '../../../../network/clients/cancel_token.dart';
import '../../../../shared/utils/result.dart';
import '../../../core/dto/query_params.dart';
import '../../../core/entities/chat/chat_admin.dart';
import '../../../core/entities/chat/chat_details.dart';
import '../../../core/entities/chat/chat_message.dart';
import '../../../shared/pagination/model.dart';

abstract class ChatRepository {
  const ChatRepository();

  FutureResult<List<ChatDetails>> getChats({
    CancellationToken? cancelToken,
  });

  FutureResult<ChatDetails> getChatDetails({
    required String chatId,
    CancellationToken? cancelToken,
  });

  FutureResult<PaginatedResponse<ChatMessage>> getMessages({
    required String chatId,
    QueryParams? params,
    CancellationToken? cancelToken,
  });

  FutureResult<int> getUnreadMessagesCount({
    CancellationToken? cancelToken,
  });

  FutureResult<List<ChatAdmin>> getAllUsers({
    CancellationToken? cancelToken,
    String? name,
  });

  FutureResult<ChatDetails> createChat({
    required String adminId,
    CancellationToken? cancelToken,
  });
}
