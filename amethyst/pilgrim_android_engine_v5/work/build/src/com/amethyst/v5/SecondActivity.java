package com.amethyst.v5;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

public class SecondActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        String msg = getIntent().getStringExtra("message");

        TextView tv = new TextView(this);
        tv.setText(msg);

        setContentView(tv);
    }
}
