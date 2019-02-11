package xyz.apollotv.kamino;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;

import java.io.File;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

  @Override
  protected void onCreate(Bundle savedInstanceState) {

    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), "xyz.apollotv.kamino/ota").setMethodCallHandler((methodCall, result) -> {
        if(methodCall.method.equals("install")){
            if(installOTA(methodCall.argument("path"))){
                result.success(true);
            }else{
                result.error("ERROR", "An error occurred whilst installing OTA updates.", null);
            }

            return;
        }

        result.notImplemented();
    });

  }

  private boolean installOTA(String path){
      try {
          Uri fileUri = Uri.parse("file://" + path);

          Intent intent;
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
              //AUTHORITY NEEDS TO BE THE SAME ALSO IN MANIFEST
              Uri apkUri = OTAFileProvider.getUriForFile(getApplicationContext(), "xyz.apollotv.kamino.provider", new File(path));
              intent = new Intent(Intent.ACTION_INSTALL_PACKAGE);
              intent.setData(apkUri);
              intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
          } else {
              intent = new Intent(Intent.ACTION_VIEW);
              intent.setDataAndType(fileUri, "application/vnd.android.package-archive");
              intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
          }

          getApplicationContext().startActivity(intent);
          return true;
      }catch(Exception ex){
          System.out.println("[Platform] Error during ApolloTV OTA installation.");
          System.out.println(ex.getMessage());
          return false;
      }
  }


}
