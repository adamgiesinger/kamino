package xyz.apollotv.kamino.share;

import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.os.Bundle;

import androidx.annotation.Nullable;

public class ClipboardShareActivity extends Activity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        CharSequence copyableText = getIntent().getCharSequenceExtra("url");
        ClipboardManager manager = (ClipboardManager) getSystemService(CLIPBOARD_SERVICE);
        manager.setPrimaryClip(ClipData.newPlainText(null, copyableText));
        finish();
    }
}
