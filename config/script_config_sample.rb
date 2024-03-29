class ScriptConfig
  USE_NOTIFY = false
  NOTIFY_HOST = 'localhost'
  NOTIFY_PORT = 8080
  NOTIFY_PATH_FORMAT = "/say?room=%s&message=%s"

  # app_id => room_name
  NOTIFY_ROOMS = {
    'com.exapmle'=>'test_room'
  }

  NOTIFY_ADDITIONAL_MESSAGE = {
    'com.exapmle'=>'http://example.com/app/com.exapmle'
  }

  GS_COMMAND = '/path/to/gsutil'
  ADMIN_EMAIL = 'admin@example.com'
end
