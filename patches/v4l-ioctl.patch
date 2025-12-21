--- a/libavdevice/v4l2.c
+++ b/libavdevice/v4l2.c
@@ -141,1 +141,1 @@ static int device_open(AVFormatContext *ctx, const char* device_path)
-    s->ioctl_f  = prefix ## ioctl;      \
+    s->ioctl_f  = (int (*)(int, int, ...))prefix ## ioctl;      \
@@ -152,1 +152,1 @@ static int device_open(AVFormatContext *ctx, const char* device_path)
-        return AVERROR(EINVAL);
+        return AVERROR(ENOSYS);
