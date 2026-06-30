<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('employee_face_embeddings', function (Blueprint $table) {
            $table->string('face_image_path')->nullable()->after('embedding');
        });
    }

    public function down(): void
    {
        Schema::table('employee_face_embeddings', function (Blueprint $table) {
            $table->dropColumn('face_image_path');
        });
    }
};
